@javascript
Feature: Add reference unsuccessfully
  Background:
    Given I am logged in
    And I go to the references page

  Scenario: Adding a reference but then cancelling
    When I follow "New"
    And I fill in "reference_title" with "Mark Wilden"
    And I press "Cancel"
    Then I should be on the references page

  Scenario: Leaving other fields blank when adding an article reference
    When I follow "New"
    And I fill in "reference_author_names_string" with "Fisher, B.L."
    And I press the "Save" button

    Then I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Journal can't be blank"
    And I should see "Series volume issue can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Leaving a required field blank should not affect other fields (article)
    When I follow "New"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ant Journal"
    And I fill in "article_pagination" with "2"
    And I press the "Save" button
    Then the "reference_title" field should contain "A reference title"

    When I follow "Article"
    Then the "reference_journal_name" field should contain "Ant Journal"
    And the "article_pagination" field should contain "2"

  Scenario: Leaving other fields blank when adding a book reference
    When I follow "New"
    And I follow "Book"
    And I fill in "reference_author_names_string" with "Fisher, B.L."
    And I press the "Save" button
    Then I should see "Year can't be blank"
    And I should see "Title can't be blank"
    And I should see "Publisher can't be blank"
    And I should see "Pagination can't be blank"

  Scenario: Leaving a required field blank should not affect other fields (book)
    When I follow "New"
    And I follow "Book"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_publisher_string" with "Capua: House of Batiatus"
    And I fill in "book_pagination" with "2"
    And I press the "Save" button
    Then the "reference_title" field should contain "A reference title"

    When I follow "Book"
    Then the "reference_publisher_string" field should contain "Capua: House of Batiatus"
    And the "book_pagination" field should contain "2"

  Scenario: Leaving other fields blank when adding a nested reference
    When I follow "New"
    And I follow "Nested"
    And I fill in "reference_author_names_string" with "Fisher, B.L."
    And I press the "Save" button
    Then I should see "Year can't be blank"
    And I should see "Pages in can't be blank"
    And I should see "Nesting reference can't be blank"

  Scenario: Adding a nested reference with a nonexistent nestee
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_citation_year" with "1981"
    And I follow "Nested"
    And I fill in "reference_pages_in" with "Pp. 32-33 in:"
    And I fill in "reference_nesting_reference_id" with "123123"
    And I press the "Save" button
    Then I should see "Nesting reference does not exist"

  Scenario: Empty author string (with separator)
    When I follow "New"
    And I fill in "reference_author_names_string" with " ; "
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"

  Scenario: Unparseable author string
    When I follow "New"
    And I fill in "reference_author_names_string" with "...asdf sdf dsfdsf"
    And I fill in "reference_title" with "A reference title"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see "Author names string couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
    And the "reference_author_names_string" field should contain "asdf"

  Scenario: Unparseable (blank) journal name
    When I follow "New"
    And I fill in "reference_title" with "A reference title"
    And I follow "Article"
    And I fill in "reference_journal_name" with ""
    And I fill in "article_pagination" with "1"
    And I press the "Save" button
    Then I should see "Journal can't be blank"
    And the "reference_title" field should contain "A reference title"

    When I follow "Article"
    Then the "reference_journal_name" field should contain ""
    And the "article_pagination" field should contain "1"

  Scenario: Unparseable publisher string
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L"
    And I fill in "reference_title" with "A reference title"
    And I follow "Book"
    And I fill in "reference_publisher_string" with "Pensoft, Sophia"
    And I fill in "book_pagination" with "1"
    And I fill in "reference_citation_year" with "1981"
    And I press the "Save" button
    Then I should see "Publisher string couldn't be parsed. In general, use the format 'Place: Publisher'."

    When I follow "Book"
    Then the "reference_title" field should contain "A reference title"
    And the "reference_publisher_string" field should contain "Pensoft, Sophia"
    And the "book_pagination" field should contain "1"
