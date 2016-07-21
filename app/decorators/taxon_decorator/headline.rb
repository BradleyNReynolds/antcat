class TaxonDecorator::Headline
  include ERB::Util
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper
  include CatalogHelper

  include RefactorHelper

  def initialize taxon
    @taxon = taxon
  end

  def headline
    content_tag :div, class: 'headline' do
      notes = headline_notes
      hol_link = link_to_hol(@taxon)
      string = headline_protonym
      string << ' ' << headline_type
      string << ' ' << notes if notes
      string << ' ' << link_to_other_site if link_to_other_site
      string << ' ' << link_to_antwiki(@taxon) if link_to_antwiki(@taxon)
      string << ' ' << hol_link if hol_link
      string
    end
  end

  private
    def headline_protonym
      protonym = @taxon.protonym
      return ''.html_safe unless protonym
      string = protonym_name protonym
      string << ' ' << headline_authorship(protonym.authorship)
      string << locality(protonym.locality)
      add_period_if_necessary(string || '')
    end

    def headline_type
      string = ''.html_safe
      string << headline_type_name_and_taxt
      string << headline_biogeographic_region
      string << ' ' unless string.empty?
      string << headline_verbatim_type_locality
      string << ' ' unless string.empty?
      string << headline_type_specimen
      string.rstrip.html_safe
    end

    def headline_type_name_and_taxt
      taxt = @taxon.type_taxt
      if not @taxon.type_name and taxt
        string = headline_type_taxt taxt
      else
        return ''.html_safe if not @taxon.type_name
        rank = @taxon.type_name.rank
        rank = 'genus' if rank == 'subgenus'
        string = "Type-#{rank}: ".html_safe
        string << headline_type_name + headline_type_taxt(taxt)
        string
      end
      content_tag :span, class: 'type' do
        add_period_if_necessary string
      end
    end

    def headline_type_name
      type = Taxon.find_by_name @taxon.type_name.to_s
      return headline_type_name_link(type) if type
      headline_type_name_no_link @taxon.type_name, @taxon.type_fossil
    end

    def headline_type_name_link type
      link_to_taxon type
    end

    def headline_type_name_no_link type_name, fossil
      rank = type_name.rank
      rank = 'genus' if rank == 'subgenus'
      name = type_name.to_html_with_fossil fossil
      content_tag :span, name, class: "#{rank} taxon"
    end

    def headline_type_taxt taxt
      add_period_if_necessary(detaxt taxt)
    end

    def headline_biogeographic_region
      return '' if @taxon.biogeographic_region.blank?
      add_period_if_necessary(@taxon.biogeographic_region)
    end

    def headline_verbatim_type_locality
      return '' if @taxon.verbatim_type_locality.blank?
      string =  '"'
      string << add_period_if_necessary(@taxon.verbatim_type_locality)
      string << '"'
    end

    def headline_type_specimen
      string = ''.html_safe
      if @taxon.type_specimen_repository.present?
        string << add_period_if_necessary(@taxon.type_specimen_repository)
      end
      if @taxon.type_specimen_code.present?
        string << ' ' unless string.empty?
        string << add_period_if_necessary(@taxon.type_specimen_code)
      end
      if @taxon.type_specimen_url.present?
        string << ' ' unless string.empty?
        s = @taxon.type_specimen_url
        string << link(s, s, target: '_blank')
      end
      string.html_safe
    end

    def protonym_name protonym
      content_tag :b, content_tag(:span, protonym_label(protonym), class: 'protonym_name')
    end

    def headline_authorship authorship
      return '' unless authorship && authorship.reference
      string = link_to_reference(authorship.reference)
      string << ": #{authorship.pages}" if authorship.pages.present?
      string << " (#{authorship.forms})" if authorship.forms.present?
      string << ' ' << detaxt(authorship.notes_taxt) if authorship.notes_taxt
      content_tag :span, string, class: :authorship
    end

    def locality locality
      return '' unless locality.present?
      locality = locality.upcase.gsub(/\(.+?\)/) {|text| text.titlecase}
      add_period_if_necessary ' ' + locality
    end

    def headline_notes
      return unless @taxon.headline_notes_taxt.present?
      detaxt @taxon.headline_notes_taxt
    end
end
