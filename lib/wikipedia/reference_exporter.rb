module Wikipedia
  class ReferenceExporter
    def self.export reference
      "Wikipedia::#{reference.type}".constantize.new(reference).format
    end

    def initialize reference
      @reference = reference
    end

    private
      def url
        @reference.url if @reference.downloadable?
      end

      def pages
        # Replace hyphens with en dashes, enwp.org/WP:ENDASH
        @reference.pagination.gsub "-", "\u2013" if @reference.pagination
      end

      def author_params
        authors = ''
        @reference.author_names.each.with_index(1) do |name, index|
          authors <<
            "|first#{index}=#{name.first_name_and_initials} " <<
            "|last#{index}=#{name.last_name} "
        end
        authors
      end

      def reference_name
        names = @reference.author_names.map &:last_name
        ref_names =
          case names.size
          when 1
            "#{names.first}"
          when 2
            "#{names.first}_&_#{names.second}"
          else
            "#{names.first}_et_al"
          end

        ref_names.tr(' ', '_') << "_#{@reference.year}"
      end
  end

  # Template: enwp.org/wiki/Template:Cite_journal
  # Looks like this: {{cite journal |last= |first= |last2= |first2= |year= |title=
  # |url= |journal= |publisher= |volume= |issue= |pages= |doi= }}
  class ArticleReference < ReferenceExporter
    def format
      <<-TEMPLATE.squish
        <ref name="#{reference_name}">{{cite journal
        #{author_params}
        |year=#{@reference.year}
        |title=#{title}
        |url=#{url if url}
        |journal=#{@reference.journal.name}
        |publisher=
        |volume=#{@reference.volume}
        |issue=#{@reference.issue unless @reference.issue.blank?}
        |pages=#{pages}
        |doi=#{@reference.doi unless @reference.doi.blank?}
        }}</ref>
      TEMPLATE
    end

    private
      def title
        title = @reference.title
        return unless title

        convert_to_wikipedia_italics title
      end

      # Asterix to double quotes (two single quotes mean "start italics" on WP);
      # also convert "pipes" to italics per ReferenceDecorator#format_italics.
      def convert_to_wikipedia_italics string
        string
          .gsub(/\*(.*?)\*/, "''\1''")
          .gsub(/\|(.*?)\|/, "''\1''")
      end
  end

  # Template: enwp.org/wiki/Template:Cite_book
  # Looks like this: {{cite book |last= |first= |year= |title= |url=
  # |location= |publisher= |page= |isbn=}}
  class BookReference < ReferenceExporter
    def format
      location = @reference.publisher.place.name
      publisher = @reference.publisher.name

      <<-TEMPLATE.squish
        <ref name="#{reference_name}">{{cite book
        #{author_params}
        |year=#{@reference.year}
        |title=#{title}
        |url=#{url if url}
        |location=#{location}
        |publisher=#{publisher}
        |pages=#{pages}
        |isbn=}}</ref>
      TEMPLATE
    end

    private
      def title
        title = @reference.title
        return unless title

        # The whole book title is italicized on WP.
        remove_italics title
      end

      def remove_italics string
        string
          .gsub(/\*(.*?)\*/, '\1')
          .gsub(/\|(.*?)\|/, '\1') # See Wikipedia::ArticleReference#title.
      end
  end
end
