require 'spec_helper'

describe UnknownReferenceDecorator do
  include TestLinksHelpers

  let(:author_name) { create :author_name, name: "Forel, A." }
  let(:reference) do
    create :unknown_reference, author_names: [author_name], citation_year: "1874",
      title: "Les fourmis de la Suisse.", citation: '*Ants* <i>and such</i>'
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      expect(reference.decorate.plain_text).to eq 'Forel, A. 1874. Les fourmis de la Suisse. Ants and such.'
    end

    context 'with unsafe tags' do
      let!(:reference) { create :unknown_reference, citation: 'Atta <script>xss</script>' }

      it "sanitizes them" do
        results = reference.decorate.plain_text
        expect(results).to_not include '<script>xss</script>'
        expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
        expect(results).to include 'Atta xss'
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        #{author_link(author_name)} 1874. <a href="/references/#{reference.id}">Les fourmis de la Suisse.</a>
        <i>Ants</i> <i>and such</i>.
      HTML
    end
  end
end