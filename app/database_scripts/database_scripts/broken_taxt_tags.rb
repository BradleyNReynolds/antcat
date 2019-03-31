# TODO: Remove.

# *Very* messy script based on another very messy script.
# https://github.com/calacademy-research/antcat/blob/
# 0b1930a3e161e756e3c785bd32d6e54867cc480c/lib/tasks/database_maintenance.rake

# rubocop:disable Naming/MemoizedInstanceVariableName
module DatabaseScripts
  class BrokenTaxtTags < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      log.puts "Searching... (in '#{Rails.env}' database)\n\n"

      matched_ids_statistics = matched_ids.map do |tag, ids|
        "#{ids.size} #{tag}(s)"
      end.to_sentence

      log.puts "\nFound #{matched_ids_statistics} (unique only)."

      log.puts "\n----------"

      log.puts "\nSearching for non-existing..."
      broken_ids = taxt_tags.keys_plus_empty_arrays
      broken_ids.each_item_in_arrays_alias :each_id
      matched_ids.each do |tag, ids|
        broken_ids[tag] = reject_existing taxt_tags[tag], ids
      end

      broken_ids_statistics = broken_ids.map { |tag, ids| "#{ids.size} #{tag}(s)" }.to_sentence
      log.puts "\nFound #{broken_ids_statistics}."

      if broken_ids.all? &:empty?
        log.puts "Found no broken tags."
        return output.string
      end

      log.puts "\n----------"

      log.puts "\nListing which...\n\n"
      broken_ids.each { |tag, ids| log.puts "#{tag}: #{ids}" }

      log.puts "\n----------"

      log.puts "\nSearching deleted...\n\n"
      broken_ids.each_id do |id, tag|
        PaperTrail::Version.where(event: 'destroy', item_type: taxt_tags[tag].to_s, item_id: id).each do |version|
          log.puts "Found #{tag} ##{id} (version id #{version.id}, #{version.event})"
        end
      end

      log.puts "\n----------"

      log.puts "\nSearching all versions...\n\n"
      broken_ids.each_id do |id, tag|
        PaperTrail::Version.where(item_id: id).each do |version|
          log.puts "Found #{tag} ##{id} (version id #{version.id})"
        end
      end

      log.puts "\n----------"

      log.puts "\nSearching for matching ids in other models (Reference, Name, Taxon)...\n\n"
      [Reference, Name, Taxon].each do |model|
        model.where(id: broken_ids.each_id).each do |item|
          log.puts "#{model}: #{item.id}"
        end
      end

      log.puts "\n----------"

      log.puts "\nListing affected taxa..."

      output.puts affected_taxa_table(taxa_with_broken_ids(broken_ids))

      log.puts "\nDone."

      output.string
    end

    def render
      markdown "<pre>#{results} #{log.string}</pre>"
    end

    private

      def output
        @_output ||= StringIO.new
      end

      def log
        @log ||= StringIO.new
      end

      def matched_ids
        @_matched_ids ||= begin
          ids = taxt_tags.keys_plus_empty_arrays
          Taxt.models_with_taxts.each_field do |field, model|
            log.puts "    #{model} --> #{field}..."
            taxt_tags.each_key do |tag|
              ids[tag] += find_all_tagged_ids model, field, tag
            end
          end
          ids.each_value &:uniq!
          ids
        end
      end

      def taxa_with_broken_ids broken_ids
        taxon_id_field = {
          ReferenceSection => 'taxon_id',
          TaxonHistoryItem => 'taxon_id',
          Taxon            => 'id'
        }
        taxon_id_field.default = "id"

        taxa_with_broken_ids_thing = []
        Taxt.models_with_taxts.each_field do |field, model|
          taxt_tags.each_key do |tag|
            model.where("#{field} LIKE '%{#{tag} %'").find_each do |matched_obj|
              matched_ids = extract_tagged_ids matched_obj.send(field), tag
              broken_matched_ids = matched_ids & broken_ids[tag]

              unless broken_matched_ids.empty?
                taxon = case matched_obj
                        when Citation then "Unknown"
                        else matched_obj.send(taxon_id_field[model]).to_i
                        end

                taxa_with_broken_ids_thing << {
                  item_id:            matched_obj.id,
                  item_type:          model.to_s,
                  taxon:              taxon,
                  tag:                tag,
                  field:              field,
                  broken_matched_ids: broken_matched_ids
                }
              end
            end
          end
        end

        taxa_with_broken_ids_thing
      end

      # HACK to fix `as_table` issue...
      def cached_results
        nil
      end

      def affected_taxa_table taxa_with_broken_ids
        as_table do |t|
          t.header :item_id, :item_type, :taxon, :tag, :broken_ids

          t.rows(taxa_with_broken_ids) do |item|
            item_id                    = item[:item_id]
            item_type                  = item[:item_type]
            taxon                      = item[:taxon]
            tag                        = item[:tag]
            field                      = item[:field]
            broken_matched_ids         = item[:broken_matched_ids]

            [
              attempt_to_link_item(item_type, item_id),
              "`#{item_type}##{field}`",
              attemp_to_link_taxon(taxon, item_type),
              tag,
              attempt_to_link_broken_ids(tag, broken_matched_ids)
            ]
          end
        end
      end

      def attemp_to_link_taxon taxon, item_type
        return '???' if item_type == "Citation"
        markdown_taxon_link(taxon)
      end

      def attempt_to_link_item item_type, item_id
        case item_type
        when "TaxonHistoryItem"
          link_to(item_id, taxon_history_item_path(item_id))
        when "ReferenceSection"
          link_to(item_id, reference_section_path(item_id))
        else
          item_id
        end
      end

      def attempt_to_link_broken_ids tag, broken_matched_ids
        broken_matched_ids.each_with_object("") do |id, string|
          string << case tag
                    when :ref
                      link_to("#{id} ", reference_history_index_path(id))
                    when :tax
                      link_to("#{id} ", taxon_history_path(id))
                    else
                      "#{id} "
                    end
        end
      end

      def taxt_tags
        return @_taxt_tags if defined? @_taxt_tags

        @_taxt_tags = {
          ref: Reference,
          nam: Name,
          tax: Taxon
        }

        def @_taxt_tags.keys_plus_empty_arrays # rubocop:disable Lint/NestedMethodDefinition
          map { |tag, _| [tag, []] }.to_h
        end

        @_taxt_tags
      end

      def reject_existing model, ids
        filter_by_existence model, ids, reject_existing: true
      end

      def extract_tagged_ids string, tag
        regex = /(?<={#{Regexp.quote(tag.to_s)} )\d*?(?=})/
        string.scan(regex).map &:to_i
      end

      def find_all_tagged_ids model, column, tag
        ids = []
        tag = tag.to_s
        model.where("#{column} LIKE '%{#{tag} %'").find_each do |matched_obj|
          matched_ids = extract_tagged_ids matched_obj.send(column), tag
          ids += matched_ids if matched_ids
        end
        ids
      end

      def filter_by_existence model, ids, options = {}
        return to_enum(:filter_by_existence, model, ids, options).to_a unless block_given?
        # Reject non-existing by default.
        reject_existing = options.fetch(:reject_existing) { false }

        if reject_existing
          Array(ids).each { |item| yield item unless model.exists? item }
        else
          Array(ids).each { |item| yield item if model.exists? item }
        end
      end
  end
end
# rubocop:enable Naming/MemoizedInstanceVariableName

__END__
description: >
  Taxt tags (eg `{ref 133005}`) that are referred to but doesn't exist.
  See %github177.
tags: [very-slow]
topic_areas: [taxt]