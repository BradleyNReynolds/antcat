require "spec_helper"

# We never really enable the patch in this spec beause it's very hard
# to remove modules have been mixed in.

describe DevMonkeyPatches do
  before do
    allow($stdout).to receive :puts # Suppress.
    allow(described_class).to receive(:enable!).and_return :stubbed
  end

  context "when in production" do
    before { allow(Rails.env).to receive(:production?).and_return true }

    it "cannot be extended" do
      expect { described_class.enable }.to raise_error /cannot/
    end
  end

  context "when in development" do
    before { allow(Rails.env).to receive(:test?).and_return false }

    it "can be enabled" do
      expect(described_class.enable).to be :stubbed
    end

    it "can be suppressed with `NO_DEV_MONKEY_PATCHES=true`" do
      expect(ENV).to receive(:[]).with("NO_DEV_MONKEY_PATCHES").and_return "yes"
      expect(described_class.enable).to be nil
    end
  end

  context "when in test" do
    it "it's not enabled by default" do
      expect { described_class.enable }.to raise_error /in test/
    end
  end

  context "when in this spec" do
    it "didn't define anything on `Object`" do
      expect(respond_to?(:dev_dev_mixed_in?)).to be false
    end
  end
end