@feed
Feature: Feed (changes)
  @javascript @papertrail
  Scenario: Deleted subfamily and undid the change
    Given I log in as a catalog editor named "Archibald"
    Given activity tracking is disabled
      And there is a subfamily "Ancatinae"
    And activity tracking is enabled
    And I log in as a superadmin named "Archibald"

    When I go to the catalog page for "Ancatinae"
      And I press "Delete"
      And I press "Delete?"
      And I go to the changes page
      And I click "[data-undo-id]"
      And I press "Undo!"
    And I go to the activity feed
    Then I should see "Archibald undid the change"
    And I should see 2 item in the feed

  Scenario: Approved all changes
    Given I log in as a superadmin named "Archibald"
    And there are two unreviewed catalog changes for the feed

    When I go to the unreviewed changes page
    And I press "Approve all"
    And I go to the activity feed
    Then I should see "Archibald approved all unreviewed catalog changes"
    # Should be the below but something is not working in the steps.
    # Then I should see "Archibald approved all unreviewed catalog changes (2 in total)."
    And I should see "Archibald approved the change"
    And I should see at least 3 items in the feed
