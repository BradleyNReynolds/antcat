require 'spec_helper'

describe Author do
  it { should be_versioned }

  it "has many names" do
    author = Author.create!
    author.names << create(:author_name)

    expect(author.names.size).to eq 1
  end

  describe "scopes.sorted_by_name" do
    it "sorts by first author name" do
      ward = create :author_name, name: 'Ward'
      fisher_b_l = create :author_name, name: 'Fisher, B. L.'
      fisher = create :author_name, name: 'Fisher', author: fisher_b_l.author
      bolton = create :author_name, name: 'Bolton'

      expect(Author.sorted_by_name).to eq [bolton.author, fisher.author, ward.author]
    end
  end

  describe ".find_by_names" do
    it "converts a list of author names to author objects" do
      bolton = create :author_name, name: 'Bolton'
      fisher = create :author_name, name: 'Fisher'

      results = Author.find_by_names ['Bolton', 'Fisher']
      expect(results).to match_array [bolton.author, fisher.author]
    end

    it "handles empty lists" do
      expect(Author.find_by_names([])).to eq []
    end
  end

  describe ".merge" do
    it "makes all the names of the passed in authors belong to the same author" do
      first_bolton_author = create(:author_name, name: 'Bolton, B').author
      second_bolton_author = create(:author_name, name: 'Bolton,B.').author
      expect(Author.count).to eq 2
      expect(AuthorName.count).to eq 2

      all_names = (first_bolton_author.names + second_bolton_author.names).uniq.sort

      Author.merge [first_bolton_author, second_bolton_author]
      expect(all_names.all? { |name| name.author == first_bolton_author }).to be_truthy

      expect(Author.count).to eq 1
      expect(AuthorName.count).to eq 2
    end
  end

  describe ".get_author_names_for_feed_message" do
    it "returns a string of author names" do
      # TODO
    end
  end
end
