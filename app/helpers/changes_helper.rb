module ChangesHelper
  def format_taxon_name name
    name.name_html.html_safe
  end

  def format_attributes taxon
    string = []
    string << 'Fossil' if taxon.fossil?
    string << 'Hong' if taxon.hong?
    string << '<i>nomen nudum</i>' if taxon.nomen_nudum?
    string << 'unresolved homonym' if taxon.unresolved_homonym?
    string << 'ichnotaxon' if taxon.ichnotaxon?
    string.join(', ').html_safe
  end

  def format_protonym_attributes taxon
    protonym = taxon.protonym
    string = []
    string << 'Fossil' if protonym.fossil?
    string << '<i>sic</i>' if protonym.sic?
    string.join(', ').html_safe
  end

  def approve_all_changes_button
    return unless user_is_superadmin?

    link_to 'Approve all', approve_all_changes_path,
      method: :put, class: "btn-destructive",
      data: { confirm: "Are you sure you want to approve all changes?" }
  end

  def changes_subnavigation_links
    [
      link_to('All Changes', changes_path),
      link_to('Unreviewed Changes', unreviewed_changes_path)
    ]
  end
end
