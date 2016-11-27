class Change < ActiveRecord::Base
  include Feed::Trackable

  belongs_to :approver, class_name: 'User'
  # TODO rename to `taxon_id`.
  belongs_to :taxon, class_name: 'Taxon', foreign_key: 'user_changed_taxon_id'

  has_many :versions, class_name: 'PaperTrail::Version'

  scope :waiting, -> { joins_taxon_states.where("taxon_states.review_state = 'waiting'") }
  scope :joins_taxon_states, -> { joins('JOIN taxon_states ON taxon_states.taxon_id = changes.user_changed_taxon_id') }

  tracked

  def self.approve_all user
    count = TaxonState.waiting.count

    Feed::Activity.without_tracking do
      TaxonState.waiting.each do |taxon_state|
        # TODO maybe something like `TaxonState#approve_related_changes`?
        Change.where(user_changed_taxon_id: taxon_state.taxon_id).each do |change|
          change.approve user
        end
      end
    end

    Feed::Activity.create_activity :approve_all_changes, count: count
  end

  def approve user = nil
    taxon_id = user_changed_taxon_id
    taxon_state = TaxonState.find_by(taxon: taxon_id)
    return if taxon_state.review_state == "approved"

    if taxon
      taxon.approve!
      update_attributes! approver: user, approved_at: Time.now
      # TODO change all `Time.now` etc to `Time.zone.now`.
    else
      # This case is for approving a delete
      # TODO? approving deletions doesn't set `approver` or `approved_at`.
      taxon_state.review_state = "approved"
      taxon_state.save!
    end

    Feed::Activity.with_tracking { create_activity :approve_change }
  end

  # TODO probably rename local `versions` now that we're in the model
  # that has a `versions` scope.
  # Once you have the change id, find all future changes that touch this
  # same item set. Find all versions, and undo the change.
  # Sort to undo changes most recent to oldest.
  def undo
    Feed::Activity.without_tracking do
      UndoTracker.clear_change
      change_id_set = find_future_changes
      versions = SortedSet[]
      items = SortedSet[]

      Taxon.transaction do
        change_id_set.each do |undo_this_change_id|
          # Could be already undone.
          current_change = Change.find_by id: undo_this_change_id
          next unless current_change

          versions.merge current_change.versions
          current_change.delete
        end
        undo_versions versions
      end
    end

    create_activity :undo_change
  end

  # TODO return as ActiveRecord instead of hash.
  def undo_items
    changes = []
    change_id_set = find_future_changes
    change_id_set.each do |current_change_id|
      # Could be already undone.
      #current_change = Change.find current_change_id
      current_change = Change.find_by id: current_change_id
      next unless current_change

      # Could get cute and report exactly what was changed about any given taxon
      # For now, just report a change to the taxon in question.
      current_taxon = current_change.most_recent_valid_taxon
      current_user = current_change.changed_by
      changes.append name: current_taxon.name.to_s,
                     change_type: current_change.change_type,
                     change_timestamp: current_change.created_at.strftime("%B %d, %Y"),
                     user_name: current_user.name

      # This would be a good place to warn from if we find that we can't undo
      # something about a taxa.
    end

    changes
  end

  def most_recent_valid_taxon
    return taxon if taxon

    version = most_recent_valid_taxon_version
    version.reify
  end

  # TODO probably move `changed_by` to a field in this model.
  # Returns the user of the person who made the change. Expensive method.
  def changed_by
    whodunnit_via_change_id || whodunnit_via_user_changed_taxon_id
  end

  private
    def whodunnit_via_change_id
      version = versions.where.not(whodunnit: nil).first
      version.try :user
    end

    # Backwards compatibility, possibly covers other cases too.
    def whodunnit_via_user_changed_taxon_id
      version = PaperTrail::Version.where(item_id: user_changed_taxon_id)
        .where.not(whodunnit: nil).last
      version.try :user
    end

    # Deletes don't store any object info, so you can't show what it used to look like.
    # used to pull an example of the way it once was.
    def most_recent_valid_taxon_version
      # "Destroy" events don't have populated data fields.
      version = versions.where(item_type: "Taxon").where.not(object: nil, event: "destroy").first
      return version if version

      # This change didn't happen to touch taxon. Go ahead and search for the most recent
      # version of this taxon that has object information
      version = PaperTrail::Version.find_by_sql(<<-SQL.squish).first
        SELECT * FROM versions WHERE item_type = 'Taxon'
        AND object IS NOT NULL
        AND item_id = '#{user_changed_taxon_id}'
        ORDER BY id DESC
      SQL
      version
    end

    # Note that because of schema change, we can't do this for changes that don't
    # have an extracted taxon_state.
    def undo_versions versions
      versions.reverse_each do |version|
        if version.event == 'create'
          undo_create_event_version version
        else
          undo_delete_event_version version
        end
      end
    end

    def undo_create_event_version version
      klass = version.item_type.constantize
      item = klass.find version.item_id
      item.delete
    end

    def undo_delete_event_version version
      item = version.reify
      unless item
        raise "failed to reify version: #{version.id} referencing change: #{version.change_id}"
      end
      begin
        # because we validate on things like the genus being present, and if we're doing an entire change set,
        # it might not be!
        item.save! validate: false if item
      rescue ActiveRecord::RecordInvalid => error
        puts "=========Reify failure: #{error} version item_type =  #{version.item_type}"
        raise error
      end
    end

    # Starting at a given version (which can reference any of a set of objects), it iterates forwards and
    # returns all changes that created future versions of said object. Exclusive of
    # the passed in object.
    def get_future_change_ids version
      new_version = version.next
      change_id = version.change_id
      return SortedSet[] unless change_id

      if new_version
        SortedSet[change_id].merge get_future_change_ids(new_version)
      else
        SortedSet[change_id]
      end
    end

    # Look up all future changes of this change, return change IDs in an array,
    # ordered most recent to oldest.
    # inclusive of the change passed as argument.
    def find_future_changes
      # This returns changes that touch future versions of
      # all paper trail type items.

      # For each change, get all the versions.
      # for each version get the change record id.
      #   Add that change record id plus its timestamp to a hash list if it isn't in there already
      #   if there is a "future" version of this version, recurse above loop.
      # sort and return the change record list.
      # because we need to go through papertrail's version
      change_ids = SortedSet[id]
      versions.each { |version| change_ids.merge get_future_change_ids(version) }
      change_ids
    end
end
