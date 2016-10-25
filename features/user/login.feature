Feature: Logging in
  As a user of AntCat
  I want to be able to log in
  So I can edit references

  Background:
    Given this user exists
      | email             | name    | password | password_confirmation |
      | email@example.com | Quintus | secret   | secret                |

  @javascript
  Scenario: Logging in successfully from the login page
    Given I am not logged in

    When I go to the login page
    Then I should not see "Logout"

    When I fill in the email field with "email@example.com"
    And I fill in the password field with "secret"
    And I press "Login"
    Then I should be on the main page
    And I should see "Logout"

  @javascript
  Scenario: Logging in unsuccessfully
    Given I am not logged in

    When I go to the main page
    And I follow "Login"
    And I fill in the email field with "email@example.com"
    And I fill in the password field with "asd;fljl;jsdfljsdfj"
    And I press "Login"
    Then I should be on the login page

  Scenario: Returning to previous page
    Given I am not logged in

    When I go to the references page
    And I follow the first "Login"
    And I fill in the email field with "email@example.com"
    And I fill in the password field with "secret"
    And I press "Login"
    Then I should be on the references page
