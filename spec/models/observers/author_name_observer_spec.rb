require 'spec_helper'

describe AuthorNameObserver do
  let(:bolton) { create :author_name, name: 'Bolton' }

  context "when an author name is changed" do
    it "is notified" do
      expect_any_instance_of(AuthorNameObserver).to receive :after_update
      bolton.name = 'Fisher'
      bolton.save!
    end

    it "invalidates the cache for all references that use the data" do
      fisher = create :author_name, name: 'Fisher'

      fisher_reference = create :article_reference, author_names: [fisher]
      ReferenceFormatterCache.instance.populate fisher_reference
      expect(fisher_reference.reload.formatted_cache).not_to be_nil

      bolton_reference1 = create :article_reference, author_names: [bolton]
      ReferenceFormatterCache.instance.populate bolton_reference1
      expect(bolton_reference1.reload.formatted_cache).not_to be_nil

      bolton_reference2 = create :article_reference, author_names: [bolton]
      ReferenceFormatterCache.instance.populate bolton_reference2
      expect(bolton_reference2.reload.formatted_cache).not_to be_nil

      AuthorNameObserver.instance.after_update bolton

      expect(bolton_reference1.reload.formatted_cache).to be_nil
      expect(bolton_reference2.reload.formatted_cache).to be_nil
      expect(fisher_reference.reload.formatted_cache).not_to be_nil
    end
  end
end
