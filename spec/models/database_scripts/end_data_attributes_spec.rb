require 'rails_helper'

describe DatabaseScripts::EndDataAttributes do
  subject(:end_data_attributes) { described_class.new(script_path) }

  context 'with a real script' do
    let(:script_path) { "app/database_scripts/database_scripts/extant_taxa_in_fossil_genera.rb" }

    describe "#title" do
      let(:script_path) { "app/database_scripts/database_scripts/fossil_protonyms_with_non_fossil_taxa.rb" }

      specify { expect(end_data_attributes.title).to eq "Fossil protonyms with non-fossil taxa" }
    end

    describe "#category" do
      specify { expect(end_data_attributes.category).to eq "Catalog" }
    end

    describe "#tags" do
      specify { expect(end_data_attributes.tags).to eq ["regression-test"] }
    end

    describe "#issue_description" do
      specify do
        expect(end_data_attributes.issue_description).to eq "The parent of this taxon is fossil, but this taxon is extant."
      end
    end

    describe "#description" do
      specify do
        expect(end_data_attributes.description).to eq "*Prionomyrmex macrops* can be ignored.\n"
      end
    end

    describe "#related_scripts" do
      let(:script_path) { "app/database_scripts/database_scripts/valid_subspecies_in_invalid_species.rb" }

      it "fetches the related scripts and excludes itself" do
        expect(end_data_attributes.related_scripts.size).to eq 1
        expect(end_data_attributes.related_scripts.first).to be_a DatabaseScripts::ValidSubspeciesInInvalidSpecies
      end
    end
  end

  context 'with canned data' do
    let(:script_path) { '' }

    let(:end_data) do
      {
        title: "Pizza Championship",
        category: "Classic pizzas",
        tags: ['pescatore, funghi'],
        issue_description: "pizza was cold",
        description: "with tuna",
        related_scripts: ["ValidSubspeciesInInvalidSpecies"]
      }
    end

    before do
      double = instance_double 'ReadEndData'
      allow(ReadEndData).to receive(:new).with(script_path).and_return(double)
      allow(double).to receive(:call).and_return(end_data)
    end

    specify { expect(end_data_attributes.title).to eq end_data[:title] }
    specify { expect(end_data_attributes.category).to eq end_data[:category] }
    specify { expect(end_data_attributes.tags).to eq end_data[:tags] }
    specify { expect(end_data_attributes.issue_description).to eq end_data[:issue_description] }
    specify { expect(end_data_attributes.description).to eq end_data[:description] }
    specify { expect(end_data_attributes.related_scripts.first).to be_a DatabaseScripts::ValidSubspeciesInInvalidSpecies }

    context 'when related scripts include a non-existing script' do
      let(:end_data) do
        {
          related_scripts: ["CountriesInEurope"]
        }
      end

      it 'returns an "unfound database script"' do
        related_script = end_data_attributes.related_scripts.first
        expect(related_script.title).to include "Error: Could not find database script with class name"
        expect(related_script.to_param).to eq 'countries_in_europe'
      end
    end
  end

  context 'with blank data' do
    let(:script_path) { '' }
    let(:end_data) { {} }

    before do
      double = instance_double 'ReadEndData'
      allow(ReadEndData).to receive(:new).with(script_path).and_return(double)
      allow(double).to receive(:call).and_return(end_data)
    end

    describe "defaults" do
      specify { expect(end_data_attributes.title).to eq nil }
      specify { expect(end_data_attributes.category).to eq '' }
      specify { expect(end_data_attributes.tags).to eq [] }
      specify { expect(end_data_attributes.issue_description).to eq nil }
      specify { expect(end_data_attributes.description).to eq '' }
      specify { expect(end_data_attributes.related_scripts).to eq [] }
    end
  end
end
