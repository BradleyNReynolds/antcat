require 'spec_helper'

describe Journal do
  it { should be_versioned }
  it { should validate_presence_of :name }

  describe "#destroy" do
    let!(:journal) { create :journal, name: "ABC" }

    context "journal without references" do
      it "works" do
        expect { journal.destroy }.to change { Journal.count }.from(1).to(0)
      end
    end

    context "journal with a reference" do
      it "doesn't work" do
        create :article_reference, journal: journal
        expect { journal.destroy }.not_to change { Journal.count }
        expect(journal.errors[:base]).to eq ["cannot delete journal (not unused)"]
      end
    end
  end
end
