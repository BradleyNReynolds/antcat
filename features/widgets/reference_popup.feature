@javascript
Feature: Reference popup
  Background:
    # Formicidae is only explicitly required by 'Selecting a reference from search results'
    # TODO leaving this here
    Given the Formicidae family exists
    And these references exist
      | authors                | year | citation_year | title              | citation   |
      | Fisher, B.             | 1995 | 1995b         | Fisher's book      | Ants 1:1-2 |
      | Bolton, B.             | 2010 | 2010 ("2011") | Bolton's book      | Ants 2:1-2 |
      | Fisher, B.; Bolton, B. | 1995 | 1995b         | Fisher Bolton book | Ants 1:1-2 |
      | Hölldobler, B.         | 1995 | 1995b         | Bert's book        | Ants 1:1-2 |

  Scenario: Seeing the popup
    When I go to the reference popup widget test page, opened to the first reference
    Then the current reference should be "Fisher, B. 1995b. Fisher's book. Ants 1:1-2"

  @search
  Scenario: Selecting a reference from search results
    Given I am logged in

    When I go to the reference popup widget test page
    And in the reference picker, I search for the author "Fisher, B."
    And I click the first search result
    Then the current reference should be "Fisher, B. 1995b. Fisher's book. Ants 1:1-2"

    When I press "OK"
    Then the widget results should be the taxt for "Fisher 1995"

  # There's a problem getting the search type selector to pick the right one
  #Scenario: Searching
  #  When I go to the reference popup widget test page
  #  And I search for "bolton"
  #  Then I should see "Bolton's book"
  #  * I should see "Fisher Bolton book"
  #  * I should not see "Bert's book"
  #  * I should not see "Fisher's book"

  @search
  Scenario: Cancelling when there's already a reference (regression)
    Given I am logged in

    When I go to the reference popup widget test page, opened to the first reference
    Then the current reference should be "Fisher, B. 1995b. Fisher's book. Ants 1:1-2"

    When in the reference picker, I search for the author "Hölldobler, B."
    And I click the first search result
    Then the current reference should be "Hölldobler, B. 1995b. Bert's book. Ants 1:1-2"

    When I press "Cancel"
    Then the widget results should be the ID for "Fisher 1995"

  @search
  Scenario: Cancelling when there's not already a reference (regression)
    Given I am logged in

    When I go to the reference popup widget test page
    Then the current reference should be "(none)"

    When in the reference picker, I search for the author "Hölldobler, B."
    And I click the first search result
    Then the current reference should be "Hölldobler, B. 1995b. Bert's book. Ants 1:1-2"

    When I press "Cancel"
    Then the widget results should be ""
