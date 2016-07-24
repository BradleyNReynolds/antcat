@feed @javascript
Feature: Feed (taxa)
  Background:
    Given I log in as a catalog editor named "Archibald"

  @search
  Scenario: Added taxon
    Given activity tracking is disabled
      And the Formicidae family exists
      And there is a subfamily "Formicinae"
      And there is a genus "Eciton"
    And activity tracking is enabled

    When I go to the edit page for "Formicinae"
      And I follow "Add genus"
        And I click the name field
          And I set the name to "Atta"
          And I press "OK"
        And I click the protonym name field
          And I set the protonym name to "Eciton"
          And I press "OK"
        And I click the authorship field
          And in the reference picker, I search for the author "Fisher"
          And I click the first search result
          And I press "OK"
        And I click the type name field
          And I set the type name to "Atta major"
          And I press "OK"
          And I press "Add this name"
        And I save my changes
    And I go to the activity feed
    Then I should see "Archibald added the genus Atta to the subfamily Formicinae" and no other feed items

  Scenario: Edited taxon
    Given I add a taxon for the feed

    When I go to the edit page for "Antcatinae"
      And I click the name field
        And I set the name to "Tactaninae"
        And I press "OK"
      And I save my changes
    And I go to the activity feed
    Then I should see "Archibald edited the subfamily Tactaninae" and no other feed items

  Scenario: Deleted taxon
    Given I add a taxon for the feed
    And I log in as a superadmin named "Archibald"

    When I go to the catalog page for "Formicidae"
      And I follow "Antcatinae" in the families index
      And I press "Delete"
      And I press "Delete?"
    And I go to the activity feed
    Then I should see "Archibald deleted the subfamily Antcatinae" and no other feed items

  Scenario: Elevated subspecies to species
    Given activity tracking is disabled
      And the Formicidae family exists
      And there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And activity tracking is enabled

    When I go to the catalog entry for "Solenopsis speccus subbus"
      And I press "Edit"
      And I will confirm on the next step
      And I follow "Elevate to species"
    And I go to the activity feed
    Then I should see "Archibald elevated the subspecies Solenopsis speccus subbus to the rank of species (now Solenopsis subbus)" and no other feed items

  Scenario: Converted species to subspecies
    Given activity tracking is disabled
      And there is a species "Camponotus dallatorei" with genus "Camponotus"
      And there is a species "Camponotus alii" with genus "Camponotus"
    And activity tracking is enabled

    When I go to the edit page for "Camponotus dallatorei"
      And I follow "Convert to subspecies"
      And I click the new species field
      And I set the new species field to "Camponotus alii"
      And I press "OK"
      And I press "Convert"
    And I go to the activity feed
    Then I should see "Archibald converted the species Camponotus dallatorei to a subspecies (now Camponotus alii dallatorei)" and no other feed items
