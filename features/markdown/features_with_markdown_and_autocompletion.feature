Feature: Features with markdown and autocompletion
  Background:
    Given I log in as a catalog editor

  Scenario: Site notices
    When I go to the new site notice form
    Then there should be a textarea with markdown and autocompletion

  Scenario: Issues
    When I go to the new issue form
    Then there should be a textarea with markdown and autocompletion

  Scenario: Comments
    Given a visitor has submitted a feedback with the comment "Cool."
    And I go to the most recent feedback item

    Then there should be a textarea with markdown and autocompletion

  Scenario: Comments (reply form)
    # Not testing this, it's just too much work.
