require "spec_helper"

describe References::Cache::Set do
  describe "#call" do
    let!(:reference) { create :article_reference }

    it "gets and sets the right values" do
      described_class[reference, 'Cache', :plain_text_cache]
      reference.reload

      expect(reference.plain_text_cache).to eq 'Cache'
    end
  end
end