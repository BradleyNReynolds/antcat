require 'spec_helper'

class FormattersAdvancedSearchTextFormatterTestClass
  include Formatters::AdvancedSearchTextFormatter
end

describe Formatters::AdvancedSearchTextFormatter do
  before do
    @formatter = FormattersAdvancedSearchTextFormatterTestClass.new
  end

  describe "Formatting" do
    it "should format in text style, rather than HTML" do
      latreille = create :author_name, name: 'Latreille, P. A.'
      science = create :journal, name: 'Science'
      reference = create :article_reference, author_names: [latreille], citation_year: '1809', title: "*Atta*", journal: science, series_volume_issue: '(1)', pagination: '3', doi: '123'
      taxon = create_genus 'Atta', incertae_sedis_in: 'genus', nomen_nudum: true
      taxon.protonym.authorship.update_attributes reference: reference
      string = @formatter.format taxon
      expect(string).to eq('Atta incertae sedis in genus, nomen nudum'+"\n"+'Latreille, P. A. 1809. Atta. Science (1):3. DOI: 123   '+reference.id.to_s+"\n\n")
    end
  end
end
