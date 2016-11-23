module ReferenceHelper
  def approve_all_references_button
    return unless user_is_superadmin?

    link_to 'Approve all', approve_all_references_path,
      method: :put, class: "btn-destructive",
      data: { confirm: "Mark all citations as reviewed? This operation cannot be undone!" }
  end

  def references_subnavigation_links
    links = []
    links << link_to('All References', references_path)
    links << link_to('Latest Additions', latest_additions_references_path)

    if user_can_edit?
      links << link_to('Latest Changes', latest_changes_references_path)

      # TODO probably allow anyone to export search results.
      if show_export_search_results_to_endnote?
        links << link_to('Export to EndNote', endnote_export_references_path(q: params[:q]))
      end
    end

    links << link_to('Journals', journals_path)
    links << link_to('Authors', authors_path)

    if user_can_edit?
      links << link_to('Merge Authors', merge_authors_path)
    end

    links
  end

  private
    def show_export_search_results_to_endnote?
      params[:action] == "search"
    end
end
