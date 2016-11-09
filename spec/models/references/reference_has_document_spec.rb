require 'spec_helper'

describe Reference do
  describe "document" do
    it "has a document" do
      reference = create :reference
      expect(reference.document).to be_nil
      reference.create_document
      expect(reference.document).not_to be_nil
    end
  end

  describe "#downloadable?" do
    context "with a document" do
      it "delegates to its document" do
        reference = create :reference, document: create(:reference_document)

        expect(reference.document).to receive :downloadable?
        reference.downloadable?
      end
    end

    context "without a document" do
      it "returns false" do
        expect(build_stubbed(:reference)).not_to be_downloadable
      end
    end
  end

  describe "#url" do
    it "is be nil if there is no document" do
      expect(build_stubbed(:reference).url).to be_nil
    end

    it "delegates to its document" do
      reference = create :reference, document: create(:reference_document)
      expect(reference.document).to receive :url
      reference.url
    end

    it "makes sure it exists" do
      reference = create :reference, year: 2001
      stub_request(:any, "http://antwiki.org/1.pdf").to_return body: "Not Found", status: 404

      expect { reference.document = ReferenceDocument.create url: 'http://antwiki.org/1.pdf' }
        .to raise_error ActiveRecord::RecordNotSaved
    end
  end

  describe "#document_host=" do
    it "doesn't crash if there is no document" do
      build_stubbed(:reference).document_host = 'localhost'
    end

    it "delegates to its document" do
      reference = create :reference, document: create(:reference_document)
      expect(reference.document).to receive :host=
      reference.document_host = 'localhost'
    end
  end
end
