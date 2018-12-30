# TODO: do not cache in database.
# TODO: refactor.

class ReferenceDecorator < ApplicationDecorator
  include ERB::Util # For the `h` method.

  delegate_all

  def public_notes
    format_italics h reference.public_notes
  end

  def editor_notes
    format_italics h reference.editor_notes
  end

  def taxonomic_notes
    format_italics h reference.taxonomic_notes
  end

  # TODO store denormalized value in the database?
  def format_date
    reference_date = reference.date
    return unless reference_date
    return reference_date if reference_date.size < 4

    match = reference_date.match /(.*?)(\d{4,8})(.*)/
    prefix = match[1]
    digits = match[2]
    suffix = match[3]

    year  = digits[0...4]
    month = digits[4...6]
    day   = digits[6...8]

    date = year
    date << '-' + month if month.present?
    date << '-' + day if day.present?

    prefix + date + suffix
  end

  # TODO rename as it also links DOIs, not just reference documents.
  def format_reference_document_link
    [doi_link, pdf_link].reject(&:blank?).join(' ').html_safe
  end

  def format_review_state
    review_state = reference.review_state

    case review_state
    when 'reviewing' then 'Being reviewed'
    when 'none', nil then ''
    else                  review_state.capitalize
    end
  end

  # Formats the reference as plaintext (with the exception of <i> tags).
  def plain_text
    return generate_plain_text if ENV['NO_REF_CACHE']

    cached = reference.plain_text_cache
    return cached.html_safe if cached

    reference.set_cache generate_plain_text, :plain_text_cache
  end

  # Formats the reference with HTML, CSS, etc. Click to show expanded.
  def expandable_reference
    return generate_expandable_reference if ENV['NO_REF_CACHE']

    cached = reference.expandable_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expandable_reference, :expandable_reference_cache
  end

  # Formats the reference with HTML, CSS, etc.
  def expanded_reference
    return generate_expanded_reference if ENV['NO_REF_CACHE']

    cached = reference.expanded_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expanded_reference, :expanded_reference_cache
  end

  def format_plain_text_title
    format_italics helpers.add_period_if_necessary make_html_safe(reference.title)
  end

  private

    def generate_plain_text
      string = make_html_safe(reference.author_names_string_with_suffix)
      string << ' ' unless string.empty?
      string << make_html_safe(reference.citation_year) << '. '
      string << helpers.unitalicize(format_plain_text_title) << ' '
      string << helpers.add_period_if_necessary(format_plain_text_citation)
      string
    end

    def generate_expandable_reference
      small_reference_link_button =
        helpers.link_to reference.id, helpers.reference_path(reference), class: "btn-normal btn-tiny"

      inner_content = []
      inner_content << generate_expanded_reference
      inner_content << small_reference_link_button
      inner_content << format_reference_document_link
      content = inner_content.reject(&:blank?).join(' ').html_safe

      # TODO: `tabindex: 2` is required or tooltips won't stay open even with `data-click-open="true"`.
      helpers.content_tag :span, reference.keey,
        data: { tooltip: true, allow_html: "true", tooltip_class: "foundation-tooltip" },
        tabindex: "2", title: content.html_safe
    end

    def generate_expanded_reference
      string = make_html_safe(reference.author_names_string_with_suffix)
      string << ' ' unless string.empty?
      string << make_html_safe(reference.citation_year) << '. '
      string << format_plain_text_title << ' '
      string << format_italics(helpers.add_period_if_necessary(format_citation))

      string
    end

    # Override in subclasses as necessary.
    def format_plain_text_citation
      # `format_citation` + `unitalicize` is go get rid of "*" italics.
      helpers.unitalicize format_italics(format_citation)
    end

    # TODO try to move somewhere more general, even if it's only used here.
    # TODO see if there's Rails version of this.
    def make_html_safe string
      return ''.html_safe if string.blank?

      string = string.dup
      quote_code = 'xdjvs4'
      begin_italics_code = '2rjsd4'
      end_italics_code = '1rjsd4'
      string.gsub! '<i>', begin_italics_code
      string.gsub! '</i>', end_italics_code
      string.gsub! '"', quote_code
      string = h string
      string.gsub! quote_code, '"'
      string.gsub! end_italics_code, '</i>'
      string.gsub! begin_italics_code, '<i>'
      string.html_safe
    end

    def format_italics string
      return unless string
      raise "Can't call format_italics on an unsafe string" unless string.html_safe?
      string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
      string.html_safe
    end

    def doi_link
      return unless reference.doi?
      helpers.external_link_to reference.doi, ("https://doi.org/" + doi)
    end

    def pdf_link
      return unless reference.downloadable?
      helpers.external_link_to 'PDF', reference.url
    end
end
