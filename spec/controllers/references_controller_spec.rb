require 'spec_helper'

describe ReferencesController do
  describe "Search" do
    describe "searching for nothing" do
      it "renders the index" do
        expect(Reference).to receive :list_references
        get :index
      end

      it "returns everything" do
        reference = create :article_reference
        get :index
        expect(Reference.list_references).to eq [reference]
      end
    end

    describe "search terms matching ids" do
      it "redirects to #show" do
        reference = reference_factory author_name: 'E.O. Wilson', id: 99999
        get :search, q: reference.id
        expect(response).to redirect_to reference_path(reference)
      end

      it "does not redirect unless the reference exists" do
        get :search, q: "11111"
        expect(response).to render_template "search"
      end
    end
  end

  describe "#latest_additions" do
    it "sorts by created_at" do
      expect(Reference).to receive(:list_references).with hash_including order: :created_at
      get :latest_additions
    end

    it "renders its own template" do
      response = get :latest_additions
      expect(response).to render_template "latest_additions"
    end
  end

  describe "#latest_changes" do
    context "logged in" do
      before { sign_in create(:editor) }

      it "renders its own template" do
        response = get :latest_changes
        expect(response).to render_template "latest_changes"
      end

      it "sorts by updated_at" do
        expect(Reference).to receive(:list_references).with hash_including order: :updated_at
        get :latest_changes
      end
    end

    context "logged out" do
      it "redirects to the sign in page" do
        expect(Reference).to_not receive :list_references
        get :latest_changes
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "#download" do
    describe "reference without a document" do
      it "raises an error" do
        expect { get :download, id: 99999, file_name: "not_even_stubbed.pdf" }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "reference with a document" do
      let!(:reference_document) { create :reference_document }

      context "with full access" do
        before do
          allow_any_instance_of(ReferenceDocument).to receive(:actual_url)
            .and_return "http://localhost/file.pdf"
          allow_any_instance_of(ReferenceDocument).to receive(:downloadable?).and_return true
        end

        it "redirects to the file" do
          response = get :download, id: reference_document.id, file_name: "not_even_stubbed.pdf"
          expect(response).to redirect_to reference_document.actual_url
        end
      end

      context "without access" do
        before do
          allow_any_instance_of(ReferenceDocument).to receive(:downloadable?).and_return false
        end

        it "redirects to the file" do
          response = get :download, id: reference_document.id, file_name: "not_even_stubbed.pdf"
          expect(response.response_code).to eq 401
        end
      end
    end
  end

  describe "autocompleting", search: true do
    let(:controller) { ReferencesController.new }

    it "autocompletes" do
      reference_factory author_name: 'E.O. Wilson'
      reference_factory author_name: 'Bolton'
      Sunspot.commit

      get :autocomplete, q: "wilson", format: :json
      json = JSON.parse response.body

      expect(json.first["author"]).to eq 'E.O. Wilson'
      expect(json.size).to eq 1
    end

    it "only autocompletes if there's matches", search: true do
      get :autocomplete, q: "willy", format: :json
      json = JSON.parse response.body
      expect(json.size).to eq 0
    end

    describe "#format_autosuggest_keywords" do
      let!(:reference) { reference_factory author_name: 'E.O. Wilson' }

      it "replaces the typed author with the suggested author" do
        keyword_params = { author: "wil" }
        search_query = controller.send :format_autosuggest_keywords, reference, keyword_params
        expect(search_query).to eq "author:'E.O. Wilson'"
      end
    end

    describe "author queries not wrapped in quotes" do
      it "handles queries containing non-English characters" do
        reference_factory author_name: 'Bert Hölldobler'
        Sunspot.commit

        get :autocomplete, q: "author:höll", format: :json
        json = JSON.parse response.body

        expect(json.first["author"]).to eq 'Bert Hölldobler'
      end

      it "handles hyphens" do
        reference_factory author_name: 'M.S. Abdul-Rassoul'
        Sunspot.commit

        get :autocomplete, q: "author:abdul-ras", format: :json
        json = JSON.parse response.body

        expect(json.first["author"]).to eq 'M.S. Abdul-Rassoul'
      end
    end
  end
end
