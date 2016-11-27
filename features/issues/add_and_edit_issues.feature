Feature: Add and edit open issues
  As an AntCat editor
  I want to add, edit and browse open issues
  So that editors can help each other to improve the catalog

  Background:
    Given I am logged in

  Scenario: No open issues
    When I go to the open issues page
    Then I should see "There are currently no open issues."

  Scenario: Adding an issue
    When I go to the open issues page
    And I follow "New"
    And I fill in "issue_title" with "Resolve homonyms"
    And I fill in "issue_description" with "Ids #999 and #777"
    And I press "Save"
    Then I should see "Successfully created issue"

    When I go to the open issues page
    Then I should see "Resolve homonyms"

  Scenario: Editing an issue
    Given there is an open issue "Restore deleted species"

    When I go to the open issues page
    Then I should see the open issue "Restore deleted species"

    When I follow "Restore deleted species"
    And I follow "Edit"
    And I fill in "issue_title" with "Restore deleted genera"
    And I fill in "issue_description" with "The genera: #7554, #8863"
    And I press "Save"
    Then I should see "Successfully updated issue"
    And I should see "The genera: #7554, #8863"

    When I go to the open issues page
    Then I should see "Restore deleted genera"
    And I should not see "Restore deleted species"

  Scenario: Re-opening a closed issue
    Given there is a closed issue "Add taxa from Aldous 2007"

    When I go to the open issues page
    Then I should see "There are currently no open issues."
    And I should see the closed issue "Add taxa from Aldous 2007"

    When I follow "Add taxa from Aldous 2007"
    And I follow "Re-open"
    Then I should see "Successfully re-opened issue"

    When I go to the open issues page
    Then I should see the open issue "Add taxa from Aldous 2007"

  Scenario: Using markdown
    Given there is an open issue "Merge 'Giovanni' authors"
    And there is a Giovanni reference

    When I go to the issue page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "issue_description" with "Ref: %reference7777"
    And I press "Save"
    Then I should see "Ref: Giovanni, 1809"

  @javascript
  Scenario: Previewing markdown
    Given there is an open issue "Merge 'Giovanni' authors"
    And there is a Giovanni reference

    When I go to the issue page for "Merge 'Giovanni' authors"
    And I follow "Edit"
    And I fill in "issue_description" with "Ref: %reference7777"
    And I follow "Preview"
    Then I should see "Ref: Giovanni, 1809"
