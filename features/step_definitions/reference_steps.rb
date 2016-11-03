Given(/^there are no references$/) do
  Reference.delete_all
end

Given(/^(?:this|these) references? exists?$/) do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    journal = create :journal, name: matches[1]

    # Not sure why this is required, but we have to do it to avoid having to
    # add empty doi fields in the Cucumber data tables. Perhaps because
    # Cucumber's "doi" hash key conflicts with FactoryGirl's :doi symbol?
    doi = hash.delete "doi"

    hash.merge! journal: journal,
      series_volume_issue: matches[2],
      pagination: matches[3],
      doi: doi

    create_reference :article_reference, hash
  end
end

Given(/(?:these|this) book references? exists?/) do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /([^:]+): (\w+), (.*)/

    publisher = create :publisher,
      name: matches[2],
      place: create(:place, name: matches[1])
    hash.merge! publisher: publisher, pagination: matches[3]
    create_reference :book_reference, hash
  end
end

# HACK because I could not get it to work in any other way.
Given(/^there is a Giovanni reference$/) do
  reference = create :article_reference,
    author_names: [],
    citation_year: '1809',
    title: "Giovanni's Favorite Ants"

  reference.update_column :id, 7777
  reference.author_names << create(:author_name, name: 'Giovanni, S.')
end

Given(/(?:these|this) unknown references? exists?/) do |table|
  table.hashes.each { |hash| create_reference :unknown_reference, hash }
end

def create_reference type, hash
  author = hash.delete 'author'
  author_names =
    if author
      [create(:author_name, name: author)]
    else
      authors = hash.delete 'authors'
      parsed_author_names = Parsers::AuthorParser.parse(authors)[:names]
      author_names_suffix = Parsers::AuthorParser.parse(authors)[:suffix]
      parsed_author_names.reduce([]) do |author_names, author_name|
        author_name = AuthorName.find_by(name: author_name) || create(:author_name, name: author_name)
        author_names << author_name
      end
    end

  hash[:year] = hash.delete('year').to_i
  hash[:citation_year] =
    if hash[:citation_year].present?
      hash.delete('citation_year').to_s
    else
      hash[:year].to_s
    end

  reference = create type, hash.merge(author_names: author_names, author_names_suffix: author_names_suffix)
  @reference ||= reference
  set_timestamps reference, hash
  reference
end

def set_timestamps reference, hash
  reference.update_column :updated_at, hash[:updated_at] if hash[:updated_at]
  reference.update_column :created_at, hash[:created_at] if hash[:created_at]
end

Given(/the following entry nests it/) do |table|
  data = table.hashes.first
  nestee_reference = @reference
  @reference = NestedReference.create! title: data[:title],
    author_names: [create(:author_name, name: data[:authors])],
    citation_year: data[:year],
    pages_in: data[:pages_in],
    nesting_reference: nestee_reference
end

Given(/that the entry has a URL that's on our site( that is public)?/) do |is_public|
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attributes file_file_name: '123.pdf',
    url: "localhost/documents/#{@reference.document.id}/123.pdf",
    public: is_public ? true : nil
end

Given(/that the entry has a URL that's not on our site/) do
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attribute :url, 'google.com/foo'
end

Then(/I should see these entries (with a header )?in this order:/) do |with_header, entries|
  offset = with_header ? 1 : 0
  entries.hashes.each_with_index do |e, i|
    expect(page).to have_css "table.references tr:nth-of-type(#{i + offset}) td", text: e['entry']
    expect(page).to have_css "table.references tr:nth-of-type(#{i + offset}) td", text: e['date']
    expect(page).to have_css "table.references tr:nth-of-type(#{i + offset}) td", text: e['review_state']
  end
end

When(/^I follow first reference link$/) do
  first('a.goto_reference_link').click
end

When(/I fill in "reference_nesting_reference_id" with the ID for "(.*?)"$/) do |title|
  reference = Reference.find_by(title: title)
  step "I fill in \"reference_nesting_reference_id\" with \"#{reference.id}\""
end

Then(/I should (not )?see a "PDF" link/) do |should_not|
  begin
    trace = ['Inside the I should(not) see a PDF step']
    page_has_no_selector = page.has_no_selector? 'a', text: 'PDF'
    trace << 'after page.has_no_selector'
    unless page_has_no_selector and should_not
      trace << 'inside unless'
      find_link("PDF").send(should_not ? :should_not : :should, be_visible)
      trace << 'after find_link'
    end
    trace << 'end'

  rescue Exception
    raise
  end
end

When(/I fill in "reference_nesting_reference_id" with its own ID$/) do
  step "I fill in \"reference_nesting_reference_id\" with \"#{@reference.id}\""
end

When(/I fill in "([^"]*)" with a URL to a document that exists/) do |field|
  stub_request :any, "google.com/foo"
  step "I fill in \"#{field}\" with \"google\.com/foo\""
end

When(/I fill in "([^"]*)" with a URL to a document that doesn't exist/) do |field|
  stub_request(:any, "google.com/foo").to_return status: 404
  step "I fill in \"#{field}\" with \"google\.com/foo\""
end

def very_long_author_names_string
  (0...26).reduce([]) do |a, n|
    a << "AuthorWithVeryVeryVeryLongName#{(?A.ord + n).chr}, A."
  end.join('; ')
end

When(/I fill in "reference_author_names_string" with a very long author names string/) do
  step %{I fill in "reference_author_names_string" with "#{very_long_author_names_string}"}
end

Then(/I should see a very long author names string/) do
  step %{I should see "#{very_long_author_names_string}"}
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  reference = create :unknown_reference, title: 'Dolerichoderinae'
  reference.update_column :id, 50000
end

Given(/^there is a missing reference(?: with citation "(.+)")?( in a protonym)?$/) do |citation, in_protonym|
  citation ||= 'Adventures among Ants'
  missing_reference = create :missing_reference, citation: citation
  if in_protonym
    create :protonym, authorship: create(:citation, reference: missing_reference)
  end
end

When(/^I click the replacement field$/) do
  step %{I click "#replacement_id_field .display_button"}
end

Then(/^I should not see the missing reference$/) do
  step 'I should not see "Adventures among Ants"'
end

# New references list
When(/^I click "(.*?)" on the Ward reference$/) do |button|
  within find("tr", text: 'Ward') do
    first(".btn-normal", text: button).click
  end
end

Then(/^the review status on the Ward reference should change to "(.*?)"$/) do |status|
  within find("tr", text: 'Ward') do
    step %{I should see "#{status}"}
  end
end

Then(/^it should (not )?show "(.*?)" as the default$/) do |should_selector, key|
  author = key.split(' ').first
  within find("tr", text: author) do
    step %{I should #{should_selector}see "Default"}
  end
end

def find_reference_by_key key
  parts = key.split ' '
  last_name = parts[0]
  year = parts[1]
  Reference.find_by(principal_author_last_name_cache: last_name, year: year.to_i)
end

Given(/^the default reference is "([^"]*)"$/) do |key|
  reference = find_reference_by_key key
  DefaultReference.stub(:get).and_return reference
end

Given(/^there is no default reference$/) do
  DefaultReference.stub(:get).and_return nil
end

When(/I fill in the references search box with "(.*?)"/) do |search_term|
  within "#breadcrumbs" do
    step %{I fill in "q" with "#{search_term}"}
  end
end

When(/I fill in the references authors search box with "(.*?)"/) do |search_term|
  within "#breadcrumbs" do
    step %{I fill in "author_q" with "#{search_term}"}
  end
end

When(/I select author search from the search type selector/) do
  select "author", from: "search_type"
end

When(/I press "Go" by the references search box/) do
  within "#breadcrumbs" do
    step 'I press "Go"'
  end
end

When(/I hover the export button/) do
  find(".btn-normal", text: "Export").hover
end

Then(/^nesting_reference_id should contain a valid reference id$/) do
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists? id).to be true
end

Given(/^there is a taxon with that reference as its protonym's reference$/) do
  taxon = create_genus
  taxon.protonym.authorship.reference = @reference
  taxon.protonym.authorship.save!
end
