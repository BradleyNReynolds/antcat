require 'spec_helper'

describe Publisher do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :place_name }

  describe 'relations' do
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end

  describe ".create_form_string" do
    context "when invalid" do
      context "when string is blank" do
        specify do
          expect { described_class.create_form_string('') }.to_not change { described_class.count }
        end
      end

      context "when name or place is missing" do
        specify do
          expect { described_class.create_form_string('Wiley') }.to_not change { described_class.count }
        end
      end
    end

    context "when valid" do
      it "creates a publisher" do
        publisher = described_class.create_form_string 'New York: Houghton Mifflin'
        expect(publisher.name).to eq 'Houghton Mifflin'
        expect(publisher.place_name).to eq 'New York'
      end

      context "when name/place combination already exists" do
        it "reuses existing publisher" do
          2.times { described_class.create_form_string("Wiley: Chicago") }
          expect(described_class.count).to eq 1
        end
      end
    end
  end

  describe "#display_name" do
    let(:publisher) { build_stubbed :publisher, name: "Wiley", place_name: 'New York' }

    specify do
      expect(publisher.display_name).to eq 'New York: Wiley'
    end
  end
end
