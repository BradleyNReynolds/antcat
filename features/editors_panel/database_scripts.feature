Feature: Database scripts
  Background:
    Given I am logged in
    And I go to the database scripts page

  Scenario: Results when there are issues
    Given there is a Lasius subspecies without a species
    And I go to the database scripts page

    When I follow "Subspecies without species"
    Then I should see "Lasius specius subspecius"

  Scenario: Results when there are no issues
    When I follow "Bad subfamily names"
    Then I should see "Found no database issues"

  Scenario: Show tags, and description with markdown
    When I follow "Bad subfamily names"
    Then I should see "regression-test"
    And I should see "From GitHub #71."

  Scenario: Script runtime and source
    When I follow "Subspecies without species"
    Then I should see "Script runtime: 0."

    When I follow "current (antcat.org)"
    Then I should see "class DatabaseScripts::Scripts::SubspeciesWithoutSpecies"

  Scenario: Clicking on all scripts just to see if the page renders
    When I open all database scripts and browse their sources
    Then I should have browsed at least 5 database scripts

  # Should not require JS, but throws `URI::InvalidURIError` without it.
  @search @javascript
  Scenario: Script: Missing references in protonym authorships
    Given the genus Atta has a protonym with a missing reference
    And this reference exists
      | authors      | citation   | year | title                  |
      | Batiatus, Q. | Psyche 2:1 | 2000 | The missing reference! |

    When I follow "Missing references in protonym authorships"
    Then I should see "Batiatus 2000"

    When I follow "Batiatus 2000"
    Then I should see "The missing reference!"
