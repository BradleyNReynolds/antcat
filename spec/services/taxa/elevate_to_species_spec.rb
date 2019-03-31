require 'spec_helper'

describe Taxa::ElevateToSpecies do
  describe "#call" do
    describe "unuccessfully elevating" do
      context "when subspecies has no species" do
        let!(:subspecies) { create :subspecies, species: nil }

        specify do
          expect { described_class[subspecies] }.to raise_error(NoMethodError)
        end
      end

      context "when a species with this name already exists" do
        let!(:genus) { create_genus 'Atta' }
        let!(:species) { create_species 'Atta major', genus: genus }
        let!(:subspecies_name) do
          SubspeciesName.create! name: 'Atta batta major',
            epithet: 'major', epithets: 'batta major'
        end
        let!(:subspecies) { create :subspecies, name: subspecies_name, species: species }

        it "returns the new new non-persister species with errors" do
          new_species = described_class[subspecies]
          expect(new_species.errors[:base]).to eq ["This name is in use by another taxon"]
        end

        it "does not create a new taxon" do
          expect { described_class[subspecies] }.to_not change { Taxon.count }
        end
      end
    end

    describe "successfully elevating" do
      context "when there is no name collision" do
        let!(:subspecies) { create :subspecies }

        it "does not modify the original subspecies record" do
          expect { described_class[subspecies] }.to_not change { subspecies.reload.attributes }
        end

        it "creates a new taxon" do
          expect { described_class[subspecies] }.to change { Taxon.count }.by(1)
        end

        it "returns the new species" do
          expect(described_class[subspecies]).to be_a Species
        end

        it "creates a new species with a species name" do
          new_species = described_class[subspecies]

          expect(new_species).to be_a Species
          expect(new_species.name).to be_a SpeciesName
        end

        it "copies relevant attributes from the original subspecies record" do
          new_species = described_class[subspecies]

          [
            :fossil,
            :status,
            :homonym_replaced_by_id,
            :incertae_sedis_in,
            :protonym,
            :type_taxt,
            :headline_notes_taxt,
            :hong,
            :unresolved_homonym,
            :current_valid_taxon,
            :ichnotaxon,
            :nomen_nudum,
            :biogeographic_region,
            :primary_type_information,
            :secondary_type_information,
            :type_notes,
            :type_taxon
          ].each do |attribute|
            expect(new_species.send(attribute)).to eq subspecies.send(attribute)
          end
        end

        it "sets relevant taxonomical relations from the original subspecies" do
          new_species = described_class[subspecies]

          expect(new_species.subfamily).to eq subspecies.subfamily
          expect(new_species.genus).to eq subspecies.genus
          expect(new_species.subgenus).to eq subspecies.subgenus
        end

        it "nilifies `species_id`" do
          expect(described_class[subspecies].species_id).to eq nil
        end

        context "when taxon has history items" do
          let!(:history_item) { create :taxon_history_item, taxon: subspecies }

          it 'moves them to the new species' do
            expect(history_item.taxon).to eq subspecies
            new_species = described_class[subspecies]
            expect(history_item.reload.taxon).to eq new_species
          end
        end
      end
    end

    # TODO these specs were left as is after rewriting this service
    # because we should stop reusing `Name`s once we're ready for that.
    context "old specs" do
      let!(:genus) { create_genus 'Atta' }

      it "forms the new species name from the epithet" do
        species = create_species 'Atta major', genus: genus
        subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
          epithet: 'colobopsis', epithets: 'major colobopsis'
        taxon = create :subspecies, name: subspecies_name, genus: genus, species: species

        described_class[taxon]

        new_species = Taxon.last

        expect(new_species.name.name).to eq 'Atta colobopsis'
        expect(new_species.name.epithet).to eq 'colobopsis'
        expect(new_species.name.epithets).to be_nil
      end

      it "creates a new species name, if necessary" do
        species = create_species 'Atta major', genus: genus
        subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
          epithet: 'colobopsis', epithets: 'major colobopsis'
        taxon = create :subspecies, name: subspecies_name, genus: genus, species: species
        name_count = Name.count

        described_class[taxon]

        expect(Name.count).to eq(name_count + 1)
      end

      it "reuses existing species name, if possible" do
        existing_species_name = create :species_name, name: "Atta colobopsis"
        species = create_species 'Atta noconflictus', genus: genus
        subspecies_name = SubspeciesName.create! name: 'Atta major colobopsis',
          epithet: 'colobopsis', epithets: 'major colobopsis'
        taxon = create :subspecies, name: subspecies_name, genus: genus, species: species

        new_species = described_class[taxon]

        expect(new_species.name).to eq existing_species_name
      end
    end
  end
end