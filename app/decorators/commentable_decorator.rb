class CommentableDecorator < Draper::Decorator
  def link_existing_comments_section
    return unless commentable.any_comments?
    helpers.antcat_icon("comment") + comments_section_link
  end

  def comments_count_in_words
    helpers.pluralize commentable.comments_count, "comment"
  end

  private

    alias_method :commentable, :object

    def comments_section_link
      label = comments_count_in_words
      helpers.link_to label, helpers.polymorphic_path(commentable) + "#comments"
    end
end
