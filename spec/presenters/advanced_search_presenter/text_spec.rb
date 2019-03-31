require 'spec_helper'

describe AdvancedSearchPresenter::Text do
  subject(:formatter) { described_class.new }

  describe "#format" do
    it "formats in text style, rather than HTML" do
      latreille = create :author_name, name: 'Latreille, P. A.'
      science = create :journal, name: 'Science'
      reference = create :article_reference,
        author_names: [latreille], citation_year: '1809',
        title: "*Atta*", journal: science,
        series_volume_issue: '(1)', pagination: '3', doi: '123'
      taxon = create :genus, incertae_sedis_in: 'genus', nomen_nudum: true
      taxon.protonym.authorship.update reference: reference

      results = formatter.format taxon
      expect(results).to eq "#{taxon.name_cache} incertae sedis in genus, nomen nudum\n" \
        "Latreille, P. A. 1809. Atta. Science (1):3. DOI: 123   #{reference.id}\n\n"
    end
  end
end