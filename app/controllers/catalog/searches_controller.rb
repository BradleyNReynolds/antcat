module Catalog
  class SearchesController < ApplicationController
    SEARCHING_FROM_HEADER = "searching_from_header"

    def show
      return if not_searching_yet? || searching_for_nothing_from_header? # Just render the form.

      if redirect_if_single_exact_match? && (single_match = Taxa::Search::SingleMatchToRedirectTo[params[:qq]])
        return redirect_to catalog_path(single_match, qq: params[:qq]), notice: <<~MSG
          You were redirected to an exact match. <a href='/catalog/search?submit_search=true&name=#{params[:qq]}'>Show more results.</a>
        MSG
      end

      if searching_for_non_existent_author?
        flash.now[:alert] = "If you're choosing an author, make sure you pick the name from the dropdown list."
        return
      end

      # TODO: Hmm.
      if params[:qq].present?
        params[:name] = params[:qq]
      end

      @taxa = Taxa::Search::AdvancedSearch[advanced_search_params]

      respond_to do |format|
        format.html do
          @taxa = @taxa.paginate(page: params[:page], per_page: params[:per_page])
        end

        format.text do
          text = @taxa.reduce('') do |content, taxon|
                   content << AdvancedSearchPresenter::Text.new.format(taxon)
                 end
          send_data text, filename: download_filename, type: 'text/plain'
        end
      end
    end

    private

      def advanced_search_params
        params.slice(:author_name, :type, :year, :name, :name_search_type, :epithet, :locality, :valid_only,
          :biogeographic_region, :genus, :forms, :type_information, :status, :fossil, :must_have_history_items,
          :nomen_nudum, :unresolved_homonym, :ichnotaxon, :hong, :collective_group_name, :incertae_sedis_in)
      end

      def not_searching_yet?
        params[:submit_search].nil?
      end

      def searching_for_nothing_from_header?
        params[:qq].blank? && searching_from_header?
      end

      def searching_for_non_existent_author?
        return if params[:author_name].blank?
        !AuthorName.where(name: params[:author_name]).exists?
      end

      def redirect_if_single_exact_match?
        searching_from_header? || antweb_legacy_route?
      end

      def searching_from_header?
        params[SEARCHING_FROM_HEADER].present?
      end

      # AntWeb's "View in AntCat" links are hardcoded to use the now
      # deprecated param "st" (starts_with). Links look like this:
      # http://www.antcat.org/catalog/search?st=m&qq=Agroecomyrmecinae&commit=Go
      # (from https://www.antweb.org/images.do?subfamily=agroecomyrmecinae)
      def antweb_legacy_route?
        params[:st].present? && params[:qq].present?
      end

      def download_filename
        "antcat_search_results__#{Time.current.strftime('%Y-%m-%d__%H_%M_%S')}.txt"
      end
  end
end
