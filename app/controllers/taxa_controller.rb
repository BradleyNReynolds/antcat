# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

# TODO extract more code from here into `Taxa::SaveTaxon`, and rename
# that class to make it more obvious that it's a form object.

class TaxaController < ApplicationController
  before_action :authenticate_editor
  before_action :authenticate_superadmin, only: [:destroy, :confirm_before_delete]
  before_action :redirect_by_parent_name_id, only: :new
  before_action :set_previous_combination, only: [:new, :create, :edit, :update]
  before_action :set_taxon, except: [:new, :create, :show]

  def new
    @taxon = get_taxon_for_create
    @default_name_string = default_name_string
    set_authorship_reference
  end

  def create
    @taxon = get_taxon_for_create
    save_taxon

    flash[:notice] = "Taxon was successfully added."

    show_add_another_species_link = @taxon.id && @taxon.is_a?(Species) && @taxon.genus
    if show_add_another_species_link
      link = view_context.link_to "Add another #{@taxon.genus.name_html_cache} species?".html_safe,
        new_taxa_path(rank_to_create: "species", parent_id: @taxon.genus.id)
      flash[:notice] += " <strong>#{link}</strong>".html_safe
    end

    # Nil check to avoid showing 404 to the user and breaking the tests
    # when we loose track of `@taxon`.
    # `change_parent.feature` fails without this, but it seems to work if the
    # steps are manually reproduced in the browser.
    if @taxon.id
      redirect_to catalog_path(@taxon)
    else
      redirect_to root_path
    end

  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :new
  end

  def edit
  end

  def update
    save_taxon

    # Same issue as in `#create`, but tests pass without this check.
    flash[:notice] = "Taxon was successfully updated."
    if @taxon.id
      @taxon.create_activity :update
      redirect_to catalog_path(@taxon)
    else
      Feed::Activity.create_activity :custom,
        parameters: { text: "updated an unknown taxon" }
      redirect_to root_path
    end

  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit
  end

  # Return all the taxa that would be deleted if we delete this
  # particular ID, inclusive. Same as children, really.
  def confirm_before_delete
    @delete_impact_list = @taxon.delete_impact_list
    render "confirm_before_delete"
  end

  def destroy
    @taxon.delete_taxon_and_children
    redirect_to root_path, notice: "Taxon was successfully deleted."
  end

  # "Light version" of `#destroy` (which is for superadmins only). A button to this
  # method is shown when there are no non-taxt references to the current taxon.
  def destroy_unreferenced
    references = @taxon.references
    if references.empty?
      @taxon.destroy
    else
      redirect_to edit_taxa_path(@taxon), notice: <<-MSG.squish
        Other taxa refer to this taxon, so it can't be deleted.
        Please talk to Stan (sblum@calacademy.org) to determine a solution.
        The items referring to this taxon are: #{references}.
      MSG
      return
    end
    redirect_to catalog_path(@taxon.parent), notice: "Taxon was successfully deleted."
  end

  # TODO move logic to model?
  def update_parent
    new_parent = Taxon.find params[:new_parent_id]
    case new_parent
    when Species   then @taxon.species = new_parent
    when Genus     then @taxon.genus = new_parent
    when Subgenus  then @taxon.subgenus = new_parent
    when Subfamily then @taxon.subfamily = new_parent
    when Family    then @taxon.family = new_parent
    end

    @taxon.save!
    redirect_to edit_taxa_path(@taxon)
  end

  def elevate_to_species
    unless @taxon.kind_of? Subspecies
      redirect_to edit_taxa_path(@taxon), notice: "Not a subspecies"
      return
    end
    @taxon.elevate_to_species
    redirect_to catalog_path(@taxon), notice: "Subspecies was successfully elevated to a species."
  end

  # Show children on another page for performance reasons.
  # Example of a very slow page: http://localhost:3000/taxa/429244/edit
  def show_children
  end

  private
    def set_previous_combination
      return unless params[:previous_combination_id].present?
      @previous_combination = Taxon.find(params[:previous_combination_id])
    end

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end

    def get_taxon_for_create
      parent = Taxon.find(params[:parent_id])

      taxon = build_new_taxon params[:rank_to_create]
      taxon.parent = parent

      # Radio button case - we got duplicates, and the user picked one
      # to resolve the problem.
      collision_resolution = params[:collision_resolution]
      if collision_resolution
        if collision_resolution == 'homonym' || collision_resolution == ""
          taxon.unresolved_homonym = true
          taxon.status = Status['homonym'].to_s
        else
          taxon.collision_merge_id = collision_resolution
          # TODO `original_combination` is never used.
          original_combination = Taxon.find(collision_resolution)
          original_combination.inherit_attributes_for_new_combination @previous_combination, parent
        end
      end

      # TODO move to Taxa::HandlePreviousCombination?
      if @previous_combination
        taxon.inherit_attributes_for_new_combination @previous_combination, parent
      end

      taxon
    end

    def save_taxon
      # `collision_resolution` will be the taxon ID of the preferred taxon or "homonym".
      collision_resolution = params[:collision_resolution]
      if collision_resolution.blank? || collision_resolution == 'homonym'
        # We get here when 1) there's no `collision_resolution` (the normal case),
        # or 2) the the editor has confirmed that we are creating a homonym.
        @taxon.save_from_form params[:taxon], @previous_combination
      else
        # TODO I believe this is where we lose track of `@taxon.id` (see nil check in `#create`)
        original_combination = Taxon.find(collision_resolution)
        original_combination.save_from_form params[:taxon], @previous_combination
      end

      if @previous_combination.is_a?(Species) && @previous_combination.children.any?
        create_new_usages_for_subspecies
      end
    end

    # TODO looks like this isn't tested
    def create_new_usages_for_subspecies
      @previous_combination.children.valid.each do |t|
        new_child = Subspecies.new

        # Only building type_name because all other will be copied from 't'.
        # TODO Not sure why type_name is not copied?
        new_child.build_type_name
        new_child.parent = @taxon

        new_child.inherit_attributes_for_new_combination t, @taxon
        new_child.save_from_form Taxa::Utility.attributes_for_new_usage(new_child, t), t
      end
    end

    def set_authorship_reference
      @taxon.protonym.authorship.reference ||= DefaultReference.get session
    end

    # TODO move to view/helper?
    def default_name_string
      return unless @taxon.kind_of? SpeciesGroupTaxon
      parent = Taxon.find(params[:parent_id])
      parent.name.name
    end

    def redirect_by_parent_name_id
      return unless params[:parent_name_id]

      if parent = Taxon.find_by(name_id: params[:parent_name_id])
        hash = {
          parent_id: parent.id,
          rank_to_create: params[:rank_to_create],
          previous_combination_id: params[:previous_combination_id],
          collision_resolution: params[:collision_resolution]
        }
        redirect_to new_taxa_path(hash)
      end
    end

    # TODO move to model?
    # This builds a `Name` without subclassing, not eg a `SpeciesName`,
    # but it seems to work OK.
    def build_new_taxon rank
      taxon_class = "#{rank}".titlecase.constantize

      taxon = taxon_class.new
      taxon.build_name
      taxon.build_type_name
      taxon.build_protonym
      taxon.protonym.build_name
      taxon.protonym.build_authorship
      taxon
    end
end
