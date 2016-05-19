@javascript
Feature: Add new nested reference button
  As an editor
  I want to add new nested references from the parent reference

  Scenario: Add new nested reference using the button
    Given this reference exist
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |
    And I am logged in
    And I go to the references page
    And I follow first reference link

    When I follow "New Nested Reference"
    Then the "reference_citation_year" field should contain "2010"
    And the "reference_pages_in" field should contain "Pp. XX-XX in:"
    And nesting_reference_id should contain a valid reference id
