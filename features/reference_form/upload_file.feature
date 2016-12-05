Feature: Upload a file
  As an editor
  I want to upload the document for a reference
  So that people can easily read it

  Scenario: Clearing the URL after uploading the file
    Given I am logged in
    And this reference exists
      | authors    | title          | citation | year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 |
    And that the entry has a URL that's on our site

    When I go to the edit page for the most recent reference
    And I fill in "reference_title" with "My Life with the Ants"
    And I fill in "reference_document_attributes_url" with ""
    And I press "Save"
    And I wait for a bit
    Then I should not see a "PDF" link
