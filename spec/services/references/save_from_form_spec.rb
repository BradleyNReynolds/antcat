require 'spec_helper'

# HACK: extra madness because RSpec had problems finding our classes.
References::ArticleReference = ArticleReference
References::BookReference = BookReference

describe References::SaveFromForm do
  context "when reference exists" do
    let(:reference) { create :unknown_reference }
    let(:reference_params) do
      {
        bolton_key: "Smith, 1858b",
        author_names_string: "Smith, F."
      }
    end
    let(:original_params) { {} }
    let(:request_host) { 123 }

    specify do
      expect(reference.bolton_key).to be nil
      described_class[reference, reference_params, original_params, request_host]
      reference.reload
      expect(reference.bolton_key).to eq reference_params[:bolton_key]
    end
  end
end
