module DatabaseScripts
  class OrphanedProtonyms < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Protonym.where("id NOT IN (SELECT protonym_id FROM taxa)")
    end

    def render
      as_table do |t|
        t.header :id, :protonym, :search_link, :created_at, :updated_at

        t.rows do |protonym|
          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            protonym_name_with_search_link(protonym),
            protonym.created_at,
            protonym.updated_at
          ]
        end
      end
    end

    private

      def protonym_name_with_search_link protonym
        # rubocop:disable Lint/UriEscapeUnescape
        search_path = "/catalog/search/quick_search?&search_type=containing&qq="
        label = 'Search'
        "<a href='#{search_path}#{URI.encode(protonym.name.name, /\W/)}'>#{label}</a>"
        # rubocop:enable Lint/UriEscapeUnescape
      end
  end
end

__END__
description: >
  Click on the protonym name to search for taxa with this name.


  It is probably safe to remove these (use:
  ```
  orphans = Protonym.where("id NOT IN (SELECT protonym_id FROM taxa)");
  orphans.each &:destroy
  ```
  )

tags: [regression-test]
topic_areas: [catalog]