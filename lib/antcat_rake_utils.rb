module AntCat
  module RakeUtils

    Hash.class_eval do
      def each_item_in_arrays options = {}
        return to_enum(:each_item_in_arrays, without_keys: true).to_a unless block_given?
        
        if options.fetch(:without_keys) { false }
          each { |key, array| array.each { |item| yield item } }
        else
          each { |key, array| array.each { |item| yield item, key } }
        end
      end

      def each_item_in_arrays_alias name
        singleton_class.send :alias_method, name, :each_item_in_arrays
      end
    end

    def models_with_taxts
      models = {
        ReferenceSection => ['references_taxt',
                             'title_taxt',
                             'subtitle_taxt'],
        TaxonHistoryItem => ['taxt'],
        Taxon            => ['headline_notes_taxt',
                             'type_taxt',
                             'genus_species_header_notes_taxt'],
        Citation         => ['notes_taxt']
      }
      models.each_item_in_arrays_alias :each_field
      models
    end

    def reject_non_existing model, ids
      # simpler code without yielding: model.where(id: ids).collect &:id
      filter_by_existence model, ids
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

    def prompt message = "Type something..", options = {}
      print "\n#{message}"
      answer = STDIN.gets.chomp
      answer = options.fetch(:default) { "y" } unless answer.present?

      abort "Quitting." if ["q", "Q"].include? answer
      return if ["n", "N"].include? answer
      yield answer if block_given?
      ActiveSupport::StringInquirer.new answer
    end

    private
      def filter_by_existence model, ids, options = {}
        return to_enum(:filter_by_existence, model, ids, options).to_a unless block_given?
        # reject non-existing by default
        reject_existing = options.fetch(:reject_existing) { false }

        if reject_existing
          Array(ids).each { |item| yield item unless model.exists? item }
        else
          Array(ids).each { |item| yield item if model.exists? item }
        end
      end
  end
end
