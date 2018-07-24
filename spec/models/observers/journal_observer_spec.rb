require 'spec_helper'

describe JournalObserver do
  let(:journal) { create :journal, name: 'Science' }

  context "when a journal is changed" do
    it "is notified" do
      expect_any_instance_of(described_class).to receive :before_update
      journal.name = 'Nature'
      journal.save!
    end

    it "invalidates the cache for the references that use the journal" do
      references = [
        create(:book_reference, journal: journal),
        create(:book_reference, journal: journal),
        create(:book_reference)
      ]

      references.each { |reference| References::Cache::Regenerate[reference] }
      references.each { |reference| expect(reference.plain_text_cache).not_to be_nil }

      described_class.instance.before_update journal

      expect(references[0].reload.plain_text_cache).to be_nil
      expect(references[1].reload.plain_text_cache).to be_nil
      expect(references[2].reload.plain_text_cache).not_to be_nil
    end
  end
end
