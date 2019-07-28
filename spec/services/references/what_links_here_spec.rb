require "spec_helper"

describe References::WhatLinksHere do
  let(:reference) { create :article_reference }

  describe "#call" do
    context 'when there are no references' do
      specify { expect(reference.what_links_here).to eq [] }
    end

    context 'when there are taxt references' do
      let(:ref_tag) { "{ref #{reference.id}}" }

      let!(:citation) { create :citation, reference: reference, notes_taxt: ref_tag }
      let!(:taxon) { create :genus, type_taxt: "{ref #{reference.id}}", headline_notes_taxt: ref_tag }
      let!(:history_item) { taxon.history_items.create!(taxt: ref_tag) }
      let!(:reference_section) { create :reference_section, title_taxt: ref_tag, subtitle_taxt: ref_tag, references_taxt: ref_tag }

      specify do
        expect(reference.reload.what_links_here).to match_array [
          TableRef.new('taxa',                :type_taxt,           taxon.id),
          TableRef.new('taxa',                :headline_notes_taxt, taxon.id),
          TableRef.new('citations',           :notes_taxt,          citation.id),
          TableRef.new('citations',           :reference_id,        citation.id),
          TableRef.new('reference_sections',  :title_taxt,          reference_section.id),
          TableRef.new('reference_sections',  :subtitle_taxt,       reference_section.id),
          TableRef.new('reference_sections',  :references_taxt,     reference_section.id),
          TableRef.new('taxon_history_items', :taxt,                history_item.id)
        ]
      end
    end

    context 'when there are references in relations' do
      let!(:taxon) { create :family }
      let!(:nested_reference) { create :nested_reference, nesting_reference: reference }

      before do
        taxon.protonym.authorship.update!(reference: reference)
      end

      specify do
        expect(reference.reload.what_links_here).to match_array [
          TableRef.new('citations',  :reference_id,         taxon.protonym.authorship.id),
          TableRef.new('references', :nesting_reference_id, nested_reference.id)
        ]
      end
    end
  end
end
