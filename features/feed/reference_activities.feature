@feed
Feature: Feed (references)
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Added reference
    When I go to the references page
      And I follow "New"
      And I fill in "reference_author_names_string" with "Ward, B.L.; Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I follow "Other"
      And I fill in "reference_citation" with "Required"
      And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the reference Ward & Bolton, 1981" and no other feed items

  @javascript
  Scenario: Edited reference
    Given there is a reference for the feed with state "reviewed"

    When I go to the edit page for the most recent reference
      And I fill in "reference_title" with "A reference title"
      And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald edited the reference Giovanni, 1809" and no other feed items

  Scenario: Started reviewing reference
    Given there is a reference for the feed with state "none"

    When I go to the new references page
      And I follow "Start reviewing"
    And I go to the activity feed
    Then I should see "Archibald started reviewing the reference Giovanni, 1809" and no other feed items

  Scenario: Finished reviewing reference
    Given there is a reference for the feed with state "reviewing"

    When I go to the new references page
      And I follow "Finish reviewing"
    And I go to the activity feed
    Then I should see "Archibald finished reviewing the reference Giovanni, 1809" and no other feed items

  Scenario: Restarted reviewing reference
    Given there is a reference for the feed with state "reviewed"

    When I go to the new references page
      And I follow "Restart reviewing"
    And I go to the activity feed
    Then I should see "Archibald restarted reviewing the reference Giovanni, 1809" and no other feed items

  Scenario: Approved all references
    Given I log in as a superadmin named "Archibald"

    When I create a bunch of references for the feed
      And I go to the references page
      And I follow "Latest Changes"
      And I follow "Approve all"
    And I go to the activity feed
    Then I should see "Archibald approved all unreviewed references (2 in total)."
    And I should see 3 items in the feed
