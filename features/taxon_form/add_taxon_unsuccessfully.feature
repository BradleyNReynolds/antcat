Feature: Adding a taxon unsuccessfully
  Background:
    Given I am logged in as a catalog editor
    And there is a subfamily "Formicinae"

  Scenario: Adding a genus without setting authorship reference
    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I press "Save"
    Then I should see "Protonym authorship reference can't be blank"

  @javascript
  Scenario: Having an error, but leave fields as user entered them
    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I fill in "taxon_type_taxt" with "Notes"
    And I press "Save"
    Then I should see "Protonym name name can't be blank"
    And the "taxon_type_taxt" field should contain "Notes"
    And the name button should contain "Atta"

  Scenario: Cancelling
    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I follow "Cancel"
    Then I should be on the catalog page for "Formicinae"