# frozen_string_literal: true

require 'rails_helper'

describe TaxonHistoryItems::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:taxon_history_item) { create :taxon_history_item }

    specify { expect(get(:show, params: { taxon_history_item_id: taxon_history_item.id })).to render_template :show }
  end
end
