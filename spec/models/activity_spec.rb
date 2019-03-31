require "spec_helper"

describe Activity, :feed do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_inclusion_of(:action).in_array Activity::ACTIONS }

  describe ".create_for_trackable" do
    context "when feed is enabled" do
      it "creates activities" do
        expect { described_class.create_for_trackable(nil, :custom) }.
          to change { described_class.count }.by 1
      end
    end

    context "when feed is disabled" do
      before { Feed.enabled = false }

      it "doesn't create activities" do
        expect { described_class.create_for_trackable(nil, :custom) }.
          not_to change { described_class.count }
      end
    end
  end
end