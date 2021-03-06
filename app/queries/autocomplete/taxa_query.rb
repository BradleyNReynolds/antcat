# frozen_string_literal: true

module Autocomplete
  class TaxaQuery
    include Service

    TAXON_ID_REGEX = /^\d+ ?$/

    attr_private_initialize :search_query, [rank: nil]

    def call
      exact_id_match || search_results
    end

    private

      def exact_id_match
        return unless search_query.match?(TAXON_ID_REGEX)
        Taxon.where(id: search_query).presence
      end

      def search_results
        taxa = Taxon.where("name_cache LIKE ? OR name_cache LIKE ?", crazy_search_query, not_as_crazy_search_query)
        taxa = taxa.where(type: rank) if rank.present?
        taxa
      end

      def crazy_search_query
        search_query.split('').join('%') + '%'
      end

      def not_as_crazy_search_query
        "%#{search_query}%"
      end
  end
end
