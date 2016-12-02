Feature: Adding a taxon unsuccessfully
  Background:
    Given I am logged in
    And these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"

  @javascript
  Scenario: Adding a genus without setting authorship reference
    Given there is a genus "Eciton"

    When I go to the edit page for "Formicinae"
    And I follow "Add genus"
    Then I should be on the new taxon page

    When I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
    And I press "Add this name"
    And I save my changes
    Then I should see "Protonym authorship reference can't be blank"

  @javascript
  Scenario: Having an error, but leave fields as user entered them
    When I go to the edit page for "Formicinae"
    And I follow "Add genus"
    And I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I fill in "taxon_type_taxt" with "Notes"
    And I save my changes
    Then I should be on the create taxon page
    And I should see "Protonym name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"
    And the name button should contain "Atta"

  Scenario: Cancelling
    When I go to the edit page for "Formicinae"
    And I follow "Add genus"
    And I follow "Cancel"
    Then I should be on the edit page for "Formicinae"

  Scenario: Show "Add species" link on genus catalog pages
    Given there is a genus "Eciton"

    When I go to the catalog page for "Eciton"
    And I follow "Add species"
    Then I should be on the new taxon page
    And I should see "new species of Eciton"
