# coding: UTF-8
class Exporters::Antweb::Exporter
  def initialize show_progress = false
    Progress.init show_progress, Taxon.count
  end

  def export_one id
    taxa = Taxon.find id
    pp export_taxon taxa
  end

  def export directory
    File.open("#{directory}/antcat.antweb.txt", 'w') do |file|
      file.puts header
      get_taxa.each do |taxon|
        begin
          if !taxon.name.nonconforming_name and !taxon.name_cache.index('?')
            row = export_taxon taxon
            if row
              if row[20]
                row[20].delete!('\"')
              end
              row.each do |col|
                if col.is_a? String
                  col.delete!("\n")
                  col.delete!("\r")
                end
              end
            end
            file.puts row.join("\t") if row
          end
        rescue Exception => e
          puts ("Fatal error exporting taxon id: #{taxon.id}")
          puts e.message
          puts e.backtrace.inspect
        end
      end
      Progress.show_results
    end

    # row = export_taxon taxon
    # file.puts row.join("\t") if row
  end

  def get_taxa
    Taxon.joins(protonym: [{authorship: :reference}]).order(:status).reverse
  end

  def export_taxon taxon
    Progress.tally_and_show_progress 100

    reference = taxon.protonym.authorship.reference
    reference_id = reference.kind_of?(MissingReference) ? nil : reference.id

    parent_taxon = taxon.parent && (taxon.parent.current_valid_taxon ? taxon.parent.current_valid_taxon : taxon.parent)
    parent_name = parent_taxon.try(:name).try(:name)
    parent_name ||= 'Formicidae'

    attributes = {
        antcat_id: taxon.id,
        status: taxon.status,
        available?: !taxon.invalid?,
        fossil?: taxon.fossil,
        history: export_history(taxon),
        author_date: taxon.authorship_string,
        author_date_html: taxon.authorship_html_string,
        original_combination?: taxon.original_combination?,
        original_combination: taxon.original_combination.try(:name).try(:name),
        authors: taxon.author_last_names_string,
        year: taxon.year && taxon.year.to_s,
        reference_id: reference_id,
        biogeographic_region: taxon.biogeographic_region,
        locality: taxon.protonym.locality,
        rank: taxon.class.to_s,
        hol_id: taxon.hol_id,
        parent: parent_name,
    }
    attributes.merge! current_valid_name: nil
    if taxon.current_valid_taxon_including_synonyms
       attributes.merge! current_valid_name: taxon.current_valid_taxon_including_synonyms.name.to_s
    end

    convert_to_antweb_array taxon.add_antweb_attributes(attributes)
  end

  def boolean_to_antweb boolean
    case boolean
      when true then
        'TRUE'
      when false then
        'FALSE'
      when nil then
        nil
      else
        raise
    end
  end

  def header
    "antcat id\t" +# [0]
        "subfamily\t" +# [1]
        "tribe\t" +# [2]
        "genus\t" +# [3]
        "subgenus\t" +# [4]
        "species\t" +# [5]
        "subspecies\t" +# [6]
        "author date\t" +# [7]
        "author date html\t" +# [8]
        "authors\t" +# [9]
        "year\t" +# [10]
        "status\t" +# [11]
        "available\t" +# [12]
        "current valid name\t" +# [13]
        "original combination\t" +# [14]
        "was original combination\t"+# [15]
        "fossil\t" +# [16]
        "taxonomic history html\t" +# [17]
        "reference id\t" +# [18]
        "bioregion\t" +# [19]
        "country\t" +# [20]
        "current valid rank\t" +# [21]
        "hol id\t" +# [22]
        "current valid parent" # [23]
  end

  def convert_to_antweb_array values
    [values[:antcat_id],
     values[:subfamily],
     values[:tribe],
     values[:genus],
     values[:subgenus],
     values[:species],
     values[:subspecies],
     values[:author_date],
     values[:author_date_html],
     values[:authors],
     values[:year],
     values[:status],
     boolean_to_antweb(values[:available?]),
     add_subfamily_to_current_valid(values[:subfamily], values[:current_valid_name]),
     boolean_to_antweb(values[:original_combination?]),
     values[:original_combination],
     boolean_to_antweb(values[:fossil?]),
     values[:history],
     values[:reference_id],
     values[:biogeographic_region],
     values[:locality],
     values[:rank],
     values[:hol_id],
     values[:parent],
    ]
  end

  def add_subfamily_to_current_valid subfamily, current_valid_name
    if current_valid_name
      return subfamily.to_s  + current_valid_name.to_s
    end
    nil
  end

  private
    include ActionView::Helpers::TagHelper # content_tag
    include ActionView::Context # content_tag

    def export_history taxon
      $use_ant_web_formatter = true # TODO remove
      begin
        taxon = taxon.decorate
        return content_tag :div, class: 'antcat_taxon' do
          content = ''.html_safe
          content << taxon.statistics(include_invalid: false)
          content << taxon.genus_species_header_notes_taxt
          content << taxon.headline
          content << taxon.history
          content << taxon.child_lists
          content << taxon.references
        end
      ensure
        $use_ant_web_formatter = false
      end
    end
end
