Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Background:
    Given I am logged in

  Scenario: Copy an article reference
    Given this reference exist
      | authors    | title          | citation | year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 |
    And I go to the page for that reference

    When I follow "Copy"
    Then the "Article" tab should be selected
    And the "reference_author_names_string" field should contain "Ward, P.S."
    And the "reference_citation_year" field should contain "1910"
    And the "article_pagination" field should contain "2"
    And the "reference_journal_name" field should contain "Ants"
    And the "reference_series_volume_issue" field should contain "1"

  Scenario: Copy a book reference
    Given this book reference exist
      | authors    | year | title | citation                |
      | Bolton, B. | 2010 | Ants  | New York: Wiley, 23 pp. |
    And I go to the page for that reference

    When I follow "Copy"
    Then the "Book" tab should be selected
    And the "reference_author_names_string" field should contain "Bolton, B."
    And the "reference_citation_year" field should contain "2010"
    And the "book_pagination" field should contain "23 pp."
    And the "reference_publisher_string" field should contain "New York: Wiley"

  Scenario: Copy a nested reference
    Given this reference exist
      | authors    | title          | citation | year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 |
    And the following entry nests it
      | authors      | title          | year | pages_in |
      | Aardvark, A. | Dolichoderinae | 2011 | In:      |
    And I go to the page for that reference

    When I follow "Copy"
    Then the "Nested" tab should be selected
    And the "reference_author_names_string" field should contain "Aardvark, A."
    And the "reference_citation_year" field should contain "2011"
    And the "reference_pages_in" field should contain "In:"
    And nesting_reference_id should contain a valid reference id

  Scenario: Copy an unknown reference
    Given this unknown reference exist
      | authors    | citation | year | citation_year | title |
      | Ward, P.S. | New York | 2010 | 2010a         | Ants  |
    And I go to the page for that reference

    When I follow "Copy"
    Then the "Other" tab should be selected
    And the "reference_author_names_string" field should contain "Ward, P.S."
    And the "reference_citation_year" field should contain "2010a"
    And the "reference_citation" field should contain "New York"

  @javascript
  Scenario: Copy a reference with a document
    Given this reference exist
      | authors    | title          | citation | year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 |
    And that the entry has a URL that's on our site
    And I go to the page for that reference

    When I follow "Copy"
    Then the "reference_document_attributes_url" field should contain ""

  @javascript
  Scenario: Copy a reference with a date
    Given this reference exist
      | authors    | title          | citation | year | date     |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 | 19900101 |
    And that the entry has a URL that's on our site
    And I go to the page for that reference

    When I follow "Copy"
    Then the "reference_title" field should contain "Annals of Ants"
    And the "reference_date" field should contain ""
