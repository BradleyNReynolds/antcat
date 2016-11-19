module DatabaseScripts::Rendering
  include DatabaseScripts::Renderers::AsTable
  include DatabaseScripts::Renderers::Plaintext
  include DatabaseScripts::Renderers::Markdown

  attr_reader :timed_render_duration

  def timed_render
    start = Time.now
    output = render
    @timed_render_duration = Time.now - start
    output
  end

  # Tries to be smart whenever not overridden in the scripts.
  def render
    case cached_results
    when ActiveRecord::Result # SQL results from `#sql`
      as_json_from_sql
    when ActiveRecord::Relation
      case cached_results.table.name # `#base_class` or `#klass` doesn't work for some reason.
        when "taxa" then as_taxon_table
        when "references" then as_reference_list
        else "Error: cannot implicitly render ActiveRecord::Relation."
      end
    else
      "Error: cannot implicitly render results."
    end
  end

  def as_taxon_table
    as_table do
      header :taxon, :status
      rows { |taxon| [ markdown_taxon_link(taxon), taxon.status ] }
    end
  end

  def as_reference_list
    list = ""
    cached_results.each do |reference|
      list << "* %reference#{reference.id}\n"
    end
    markdown list
  end

  def as_json_from_sql
    output = cached_results.to_json

    if defined? no_database_issues_on_on
      return no_database_issues if output == no_database_issues_on_on
    end

    output
  end

  def no_database_issues
    "Found no database issues"
  end
end
