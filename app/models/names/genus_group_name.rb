class GenusGroupName < Name
  def name_to_html
    italicize name
  end

  def epithet_to_html
    italicize epithet
  end

  def dagger_html
    italicize super
  end
end
