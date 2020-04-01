# frozen_string_literal: true

# Class for generating Wikipedia {{AntCat}} citation templates.
# https://en.wikipedia.org/wiki/Template:AntCat

module Wikipedia
  class CiteTemplate
    include Service

    attr_private_initialize :taxon

    def call
      %(<ref name="AntCat">#{cite_template}</ref>)
    end

    private

      def cite_template
        <<-TEMPLATE.squish
          {{AntCat|#{taxon.id}|#{taxon_name}|#{year}|accessdate=#{accessdate}}}
        TEMPLATE
      end

      def taxon_name
        name = taxon.name_cache
        name = "''#{name}''" if taxon.class.in? [Genus, Species, Subspecies]

        "#{dagger if taxon.fossil?}#{name}"
      end

      def dagger
        "†"
      end

      def accessdate
        Time.zone.now.strftime "%-d %B %Y"
      end

      def year
        Time.zone.now.year
      end
  end
end
