# frozen_string_literal: true

When("I write a new comment {string}") do |body|
  first("#comment_body").set body
end

Given('Batiatus has commented "Cool" on an issue with the title "Typos"') do
  issue = create :issue, title: "Typos"
  user = User.find_by!(name: "Batiatus")
  Comment.build_comment(issue, user, body: "Cool").save!
end

Then("I should see a comments section") do
  find ".comments-section"
end

# HACK: x 2:
#   * We're only checking that the URL contains the string "#comment-" (anchor tag).
#   * We're getting the URL via JavaScript because I could not get Capybara to do it.
Then("I should see my comment highlighted in the comments section") do
  url_via_javascript = page.evaluate_script "window.location.href"
  expect(url_via_javascript).to include "#comment-"
end

When("I hover the comment") do
  find(".highlight-comment-anchor").hover
end
