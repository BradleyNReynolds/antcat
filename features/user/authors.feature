Feature: Working with authors and their names

  Scenario: Not logged in
    Given the following names exist for an author
      | Bolton, B. |
      | Bolton,B.  |
    And the following names exist for another author
      | Fisher, B. |
    When I go to the authors page
    Then I should see "Bolton, B.; Bolton,B."
    And I should see "Fisher, B."
    And I should not see "edit" in the first row of author names

  Scenario: Seeing all the authors with their names
    Given the following names exist for an author
      | Bolton, B. |
      | Bolton,B.  |
    And the following names exist for another author
      | Fisher, B. |
    Given I am logged in
    When I go to the authors page
    Then I should see "Bolton, B.; Bolton,B."
    And I should see "Fisher, B."
    When I click "edit" in the first row
    Then I should be on the author edit page for "Bolton, B."

  Scenario: Attempting to access edit page without being logged in
    Given the following names exist for an author
      | Bolton, B. |
    When I go to the author edit page for "Bolton, B."
    Then I should be on the login page

  @javascript
  Scenario: Adding an author name
    Given the following names exist for an author
      | Bolton, B. |
    Given I am logged in
    When I go to the author edit page for "Bolton, B."
    And I click the "Add Author Name" button
    And I edit the author name to "Fisher, B."
    And I save the author name
