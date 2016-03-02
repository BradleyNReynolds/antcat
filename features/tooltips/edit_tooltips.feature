Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that other editors can understand how to edit the catalog

      # TEST: Click on (I), create a tooltip, save it, end up on origin page with new tooltip visible
    # Test, go to tooltip creation directly, create a tooltip, save it, remain on tooltip page.
    # TEST: click tooltip, go to edit screen. When done editing, warp to source page
    # Test: go directly to edit, edit, see 'Tooltip was successfully updated.'
    # test: click new (i) icon for existing tooltip, get same edit behaviour as clicking "?".
    # Test: Click "?" icon when not superadmin, nothing happens.
    # Test: Ensure that the window comes up with selector and key enabled
    # Test: superadmins and admins should be able to edit tooltips. nobody else.
    # Test: Create a tooltip with a page identifier, ensure it shows up
    # Test: Create a tooltip with the same selector as above, diffierett page origin, ensure it does not show up
    # Test: Ensure page renders when there are no tooltips
    # Test: ensure no (i) icons, click http://localhost:3000/tooltips, Show tooltips helper, see (i) icons.
    # Test: see (i) icons, click "Hide tooltips helper", see no (i) icons.
    # Test: Make sure edit links are disabled if no edit privs? Does that even make sense? right now you only see
    #       tooltips for edit-able pages.

  Background:
    Given I am logged in

  Scenario: Listing all tooltips
    Given this tooltip exist
      | key      | key_enabled | text        | scope |
      | selector | true        | Is enabled! | test  |

    When I go to the tooltips editing page
    Then I should see "Edit Tooltips"
    And I should see "Is enabled!"

  @javascript
  Scenario: Hovering a tooltip
    Given this tooltip exists
      | key       | key_enabled | text      | scope |
      | hardcoded | true        | A tooltip | test  |

    When I go to the tooltips test page
    Then I should not see the tooltip text "A tooltip"

    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "A tooltip"

  @javascript
  Scenario: Adding a key-based tooltip
    When I go to the tooltips test page
    And I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Could not find tooltip with key 'hardcoded'"

    Then I go to the tooltips editing page
    And I follow "New Tooltip"
    And I fill in "tooltip[key]" with "hardcoded"
    And I check "tooltip[key_enabled]"
    And I fill in "tooltip[scope]" with "tooltips"
    And I fill in "tooltip[text]" with "Text used in the tooltip"
    Then I press "Create Tooltip"
    And I wait for a bit

    Then I go to the tooltips test page
    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Text used in the tooltip"

  @javascript
  Scenario: Editing a selector-based tooltip
    Given this tooltip exists
      | key      | text      | selector | selector_enabled | scope |
      | whatever | Typo oops | li.title | true             | test  |

    When I go to the tooltips test page
    Then I should not see the tooltip text "Typo oops"

    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "Typo oops"

    Then I go to the tooltips editing page
    And I follow "title"

    Then I fill in "tooltip[text]" with "A title"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips test page
    Then I should not see the tooltip text "Typo oops"
    And I should not see the tooltip text "A title"

    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "A title"

  @javascript
  Scenario: Disabling a key-based tooltip
    Given this tooltip exist
      | key       | key_enabled | text       | scope |
      | hardcoded | true        | Is enabled | test  |

    When I go to the tooltips test page
    Then I should not see the tooltip text "Is enabled"

    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Is enabled"

    Then I go to the tooltips editing page
    And I follow "hardcoded"

    And I follow "Hide/show advanced"
    Then I uncheck "tooltip[key_enabled]"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips test page
    Then I should not see any tooltips next to the text "Hardcoded"

  @javascript
  Scenario: Disabling a selector-based tooltip
    Given this tooltip exists
      | key      | text    | selector | selector_enabled | scope |
      | whatever | A title | li.title | true             | test  |

    When I go to the tooltips test page
    And I wait for a bit
    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "A title"

    Then I go to the tooltips editing page
    And I wait for a bit
    And I follow "whatever"

    And I follow "Hide/show advanced"
    Then I uncheck "tooltip[selector_enabled]"
    And I press "Update Tooltip"
    And I wait for a bit

    Then I go to the tooltips test page
    Then I should not see any tooltips next to the element containing "Hook"

  @javascript
  Scenario: Page based exclusion works.
    When I go to the tooltips editing page
    And I hover the tooltip next to the text "Tooltip text"
    Then I should see the tooltip text "Could not find tooltip with key 'text'"

    Then I follow "New Tooltip"
    And I fill in "tooltip[key]" with "text"
    And I follow "Hide/show advanced"
    And I check "tooltip[key_enabled]"
    And I fill in "tooltip[scope]" with "tooltips2"
    And I fill in "tooltip[text]" with "Text used in the tooltip"
    Then I press "Create Tooltip"
    And I wait for a bit

    Then I go to the tooltips editing page
    When I hover the tooltip next to the text "Tooltip text"
    Then I should not see the tooltip text "Text used in the tooltip"

  @javascript
  Scenario: toggle i helpers
    When I go to the tooltips editing page
    And I follow "Show tooltips helper"
    Then I should see "Hide tooltips helper"
    And I follow "Hide tooltips helper"
    Then I should see "Show tooltips helper"
