# NOTE that this service mutates `params`, but that's OK for now.

module References
  class SaveFromForm
    include Service

    def initialize reference, params, request_host
      @reference = reference
      @params = params
      @request_host = request_host
    end

    def call
      save
    end

    private
      attr_reader :params, :request_host

      def save
        Reference.transaction do
          clear_document_params_if_necessary
          set_pagination
          clear_nesting_reference_id unless @reference.kind_of? NestedReference
          parse_author_names_string
          set_journal if @reference.kind_of? ArticleReference
          set_publisher if @reference.kind_of? BookReference

          # Set attributes to make sure they're persisted in the form.
          @reference.attributes = params[:reference]

          # Raise if there are errors -- #save! clears the errors
          # before validating, so we need to manually raise here.
          raise ActiveRecord::Rollback if @reference.errors.present?

          unless params[:ignore_possible_duplicate].present?
            if @reference.check_for_duplicate
              params[:ignore_possible_duplicate] = "yes"
              raise ActiveRecord::Rollback
            end
          end

          @reference.save!
          set_document_host

          return true
        end
      rescue ActiveRecord::RecordInvalid
        return false
      end

    def set_pagination
      params[:reference][:pagination] =
        case @reference
        when ArticleReference then params[:article_pagination]
        when BookReference    then params[:book_pagination]
        else                       nil
        end
    end

    def set_document_host
      @reference.document_host = request_host
    end

    def parse_author_names_string
      author_names_and_suffix = @reference.parse_author_names_and_suffix params[:reference].delete(:author_names_string)
      @reference.author_names.clear
      params[:reference][:author_names] = author_names_and_suffix[:author_names]
      params[:reference][:author_names_suffix] = author_names_and_suffix[:author_names_suffix]
    end

    def set_journal
      journal_name = params[:reference][:journal_name]

      # Set journal_name for the form.
      @reference.journal_name = journal_name

      # Set nil or valid publisher in the params.
      journal = Journal.find_or_create_by(name: journal_name)
      params[:reference][:journal] = journal.valid? ? journal : nil
    end

    def set_publisher
      publisher_string = params[:reference][:publisher_string]

      # Set publisher_string for the form.
      @reference.publisher_string = publisher_string

      # Add error or set valid publisher in the params.
      publisher = Publisher.create_with_place_form_string publisher_string
      if publisher.nil? && publisher_string.present?
        @reference.errors.add :publisher_string,
          "couldn't be parsed. In general, use the format 'Place: Publisher'."
      else
        params[:reference][:publisher] = publisher
      end
    end

    def clear_nesting_reference_id
      params[:reference][:nesting_reference_id] = nil
    end

    def clear_document_params_if_necessary
      return unless params[:reference][:document_attributes]
      return unless params[:reference][:document_attributes][:url].present?
      params[:reference][:document_attributes][:id] = nil
    end
  end
end
