# frozen_string_literal: true

require 'rails_helper'

describe References::FindDuplicates do
  let(:reference_similarity) { double }

  before do
    allow(References::ReferenceSimilarity).to receive(:new).with(target, match).
      and_return(reference_similarity)
  end

  describe "#call" do
    let!(:match) { create :article_reference, author_string: 'Ward, P.S.' }
    let(:target) { create :article_reference, author_string: 'Ward' }

    context "when an obvious mismatch" do
      it "doesn't match" do
        expect(reference_similarity).to receive(:call).and_return(0.00)
        expect(described_class[target]).to be_empty
      end
    end

    context "when an obvious match" do
      it "matches" do
        expect(reference_similarity).to receive(:call).and_return(0.10)
        expect(described_class[target, min_similarity: 0.01]).to eq [
          { similarity: 0.10, target: target, match: match }
        ]
      end
    end

    context "with an author last name with an apostrophe in it (regression)" do
      let!(:match) { create :article_reference, author_string: "Arnol'di, G." }
      let(:target) { create :article_reference, author_string: "Arnol'di" }

      it "handles it" do
        expect(reference_similarity).to receive(:call).and_return(0.10)
        expect(described_class[target, min_similarity: 0.01]).to eq [
          { similarity: 0.10, target: target, match: match }
        ]
      end
    end
  end
end
