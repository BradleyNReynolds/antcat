@javascript
Feature: Preview markdown
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Previewing references markdown
    Given there is a Giovanni reference
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "task_description" with "See: %reference7777"
    And I follow "Preview"
    Then I should see "See: Giovanni, 1809"

    # Test reference expansion.
    And I should not see "Giovanni's Favorite Ants"
    When I follow "Giovanni, 1809"
    Then I should see "Giovanni's Favorite Ants"

  Scenario: Previewing taxa markdown
    Given there is a genus "Eciton"
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in the markdown textarea with "@taxon" followed by Eciton's id
    And I follow "Preview"
    Then I should see "Eciton"

  Scenario: Previewing users markdown
    Given I am on a page with a textarea with markdown preview and autocompletion

    When I fill in the markdown textarea with "@user" followed by my user id
    And I follow "Preview"
    Then I should see a link to the user page for "Archibald"

  # Testing multiple at the same time because JS tests are painfully slow.
  Scenario: Previewing journal, task and feedback markdown
    Given a journal exists with a name of "Ant Science 2000"
    And there is a closed task "Cleanup synonyms"
    And a visitor has submitted a feedback
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in the markdown textarea with markdown links for the above
    And I follow "Preview"
    Then I should see "Ant Science 2000"
    And I should see "(Cleanup synonyms)"
    And I should see "feedback #"
