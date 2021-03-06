# frozen_string_literal: true

require 'rails_helper'

describe CommentableDecorator do
  subject(:decorated) { described_class.new(commentable) }

  describe "#link_existing_comments_section" do
    context 'when commentable has no comments' do
      let(:commentable) { build_stubbed :issue }

      specify { expect(decorated.link_existing_comments_section).to eq nil }
    end

    context 'when commentable has comments' do
      let(:commentable) { create :issue }

      before do
        create :comment, commentable: commentable
      end

      specify do
        expect(decorated.link_existing_comments_section).
          to eq %(<i class="antcat_icon comment"></i><a href="/issues/#{commentable.id}#comments">1 comment</a>)
      end
    end
  end
end
