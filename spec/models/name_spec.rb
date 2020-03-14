require 'rails_helper'

describe Name do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:protonyms).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:taxa).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :epithet }

    describe '#ensure_starts_with_upper_case_letter' do
      let(:name) { build_stubbed :genus_name, name: 'lasius' }

      specify do
        expect(name.valid?).to eq false
        expect(name.errors[:name]).to eq ["must start with a capital letter"]
      end
    end
  end

  describe "#italics?" do
    specify do
      expect(FamilyName.new.italics?).to eq false
      expect(SubfamilyName.new.italics?).to eq false
      expect(TribeName.new.italics?).to eq false
      expect(SubtribeName.new.italics?).to eq false

      expect(GenusName.new.italics?).to eq true
      expect(SubgenusName.new.italics?).to eq true
      expect(SpeciesName.new.italics?).to eq true
      expect(SubspeciesName.new.italics?).to eq true
      expect(InfrasubspeciesName.new.italics?).to eq true
    end
  end

  describe '#set_epithet' do
    let!(:name) { SubspeciesName.new(name: 'Lasius niger fusca') }

    before do
      name.attributes = { epithet: 'pizza' }
    end

    specify { expect { name.save }.to change { name.epithet }.from('pizza').to('fusca') }
  end

  describe "#name_with_fossil_html" do
    it "formats the fossil symbol" do
      expect(SpeciesName.new(name: 'Atta major').name_with_fossil_html(false)).to eq '<i>Atta major</i>'
      expect(SpeciesName.new(name: 'Atta major').name_with_fossil_html(true)).to eq '<i>&dagger;</i><i>Atta major</i>'
    end
  end

  describe "#set_taxon_caches" do
    let!(:eciton_name) { create :genus_name, name: 'Eciton' }

    context 'when name is assigned to a taxon' do
      let!(:taxon) { create :genus }

      it "sets the taxons's `name_cache` and `name_html_cache`" do
        expect { taxon.update!(name: eciton_name) }.
          to change { taxon.reload.name_cache }.to('Eciton').
          and change { taxon.reload.name_html_cache }.to('<i>Eciton</i>')
      end
    end

    context 'when the contents of the name change' do
      let!(:taxon) { create :genus, name: eciton_name }

      it "changes the cache" do
        expect { eciton_name.update!(name: 'Atta') }.
          to change { taxon.reload.name_cache }.to('Atta').
          and change { taxon.reload.name_html_cache }.to('<i>Atta</i>')
      end
    end
  end
end
