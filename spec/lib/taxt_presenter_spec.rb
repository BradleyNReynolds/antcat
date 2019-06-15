require "spec_helper"

describe TaxtPresenter do
  describe "#to_html" do
    context 'with unsafe tags' do
      let(:reference) { create :unknown_reference, citation: 'Latreille, 1809 <script>xss</script>' }

      it "sanitizes them" do
        expect(described_class["{ref #{reference.id}} <script>xss</script>"].to_html).to_not include 'script'
      end
    end

    it "handles nil" do
      expect(described_class[nil].to_html).to eq ''
    end

    specify { expect(described_class['string'].to_html).to be_html_safe }
  end
end
