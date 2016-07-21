require 'spec_helper'

describe Api::V1::CitationsController do
  describe "getting data" do
    it "gets all citations greater than a given number" do
      create_taxon
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      # Get index starting at four
      get(:index, starts_at: species.id)
      expect(response.status).to eq(200)
      citations=JSON.parse(response.body)
      # since we want no ids less than 4, we should get a starting id at 4
      expect(citations[0]['citation']['id']).to eq(species.id)
      expect(citations.count).to eq(1)
    end

    it "gets all citations" do
      create_taxon
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      get(:index, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("pages")

      citations=JSON.parse(response.body)
      expect(citations.count).to eq(7)
    end
  end
end
