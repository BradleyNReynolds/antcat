require 'spec_helper'

describe AdvancedSearchPresenter::HTML do
  let(:taxon) { create :genus, :unavailable, incertae_sedis_in: 'genus', nomen_nudum: true }

  describe "#format_status_reference" do
    specify do
      expect(described_class.new.format_status_reference(taxon)).to eq "<i>incertae sedis</i> in genus, <i>nomen nudum</i>"
    end
  end
end
