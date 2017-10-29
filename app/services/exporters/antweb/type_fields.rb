class Exporters::Antweb::TypeFields
  include ApplicationHelper
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    formatted_type_fields.reject(&:blank?).join(' ').html_safe
  end

  private
    attr_reader :taxon

    def formatted_type_fields
      [published_type_information, additional_type_information, type_notes]
    end

    def published_type_information
      return unless taxon.published_type_information.present?
      add_period_if_necessary taxon.published_type_information
    end

    def additional_type_information
      return unless taxon.additional_type_information.present?
      add_period_if_necessary "Additional type information: #{taxon.additional_type_information}"
    end

    def type_notes
      return unless taxon.type_notes.present?
      add_period_if_necessary "Type notes: #{taxon.type_notes}"
    end
end
