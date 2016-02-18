crumb :references do
  link "References", references_path
end

  crumb :reference do |reference|
    link "Reference ##{reference.id}", reference_path(reference)
    parent :references
  end

  crumb :new_reference do
    link "New"
    parent :references
  end

  crumb :edit_reference do |reference|
    link "Edit"
    parent :reference, reference
  end

crumb :references_search_results do
  link "Search Results"
  parent :references
end

crumb :all_references do
  link "All References", references_path
  parent :references
end

crumb :references_latest_additions do
  link "Latest Additions", latest_additions_references_path
  parent :references
end

crumb :references_latest_changes do
  link "Latest Changes", latest_changes_references_path
  parent :references
end

crumb :missing_references do
  link "Missing References", missing_references_path
  parent :references
end

  crumb :show_and_fix_missing_reference do |reference|
    link "Show/Fix Missing Reference ##{reference.id}"
    parent :missing_references
  end

crumb :journals do
  link "Journals", journals_path
  parent :references
end

  crumb :journal do |journal|
    link "Journal ##{journal.id}", journal_path(journal)
    parent :journals
  end

    crumb :edit_journal do |journal|
      link "Edit"
      parent :journal, journal
    end

  crumb :new_journal do
    link "New Journal"
    parent :journals
  end

crumb :authors do
  link "Authors", authors_path
  parent :references
end

  crumb :show_and_edit_author do |author|
    link "Show/Edit Author ##{author.id}"
    parent :authors
  end

  crumb :merge_authors do
    link "Merge Authors"
    parent :authors
  end
