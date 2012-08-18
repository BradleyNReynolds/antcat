# coding: UTF-8
class Importers::Bolton::Catalog::Species::History
  attr_reader :status, :epithets

  def initialize history
    @history = history
    @index = 0
    @status = 'valid'
    determine_status
  end

  def determine_status
    while get_next_item
      return if check_definitive_status_indicators
      check_status_as_species or
      check_synonym or
      check_homonym or
      check_having_subspecies or
      check_revival_from_synonymy or
      check_unavailable_name or
      check_unidentifiable or
      check_nomen_nudum or
      check_excluded
    end
  end

  def check_definitive_status_indicators
    return true if check_first_available_replacement
    if @item[:subspecies] or @item[:currently_subspecies_of]
      @status = 'valid'
      return true
    end
  end

  def check_status_as_species
    if @item[:status_as_species]
      @status = 'valid'
      return true
    end
  end

  def check_homonym
    if @item[:homonym_of]
      if @item[:homonym_of][:unresolved]
        skip_rest_of_history
        @status = 'unresolved homonym'
        return true
      else
        item = peek_next_item
        if item && item[:matched_text] =~ /First replacement name: <i>(\w+)<\/i>/
          @epithets = [$1]
          get_next_item
        end
        @status = 'homonym'
        return true
      end

    elsif text_matches?(@item, 'Unresolved junior primary homonym')
      skip_rest_of_history
      @status = 'unresolved homonym'
      return true

    elsif @item[:matched_text] =~ /\bhomonym\b/i
      @status = 'homonym'
      return true

    end
  end

  def check_having_subspecies
    if @item[:subspecies]
      @status = 'valid'
      return true
    end
  end

  def check_synonym
    if @item[:matched_text] =~ /Unnecessary replacement.*?hence junior synonym of <i>(\w+)<\/i>/
      @status = 'synonym'
      @epithets = [$1]
      return true
    elsif @item[:synonym_ofs]
      @status = 'synonym'
      @epithets = @item[:synonym_ofs].map {|e| e[:species_epithet]}
      return true
    end
  end

  def check_revival_from_synonymy
    if @item[:revived_from_synonymy] ||
       @item[:raised_to_species].try(:[], :revived_from_synonymy)
      @status = 'valid'
      return true
    end
  end

  def check_unidentifiable
    if @item[:unidentifiable] || text_matches?(@item, /unidentifiable/i)
      @status = 'unidentifiable'
      return true
    end
  end

  def check_excluded
    if text_matches? @item, /Excluded from Formicidae/i
      @status = 'unidentifiable'
      return true
    end
  end

  def check_first_available_replacement
    return false if text_matches? @item, 'oldest synonym and hence first available replacement name'
    if text_matches?(@item, /(First|hence first) available replacement/) ||
       text_matches?(@item, /Replacement name for/)
      @status = 'valid'
      return true
    end
  end

  def check_unavailable_name
    if @item[:unavailable_name]
      @status = 'unavailable'
      return true
    end
  end

  def check_nomen_nudum
    if @item[:nomen_nudum]
      @status = 'nomen nudum'
      return true
    end
  end

  def check_excluded
    if text_matches? @item, /Excluded from Formicidae/i
      @status = 'excluded'
      return true
    end
  end

  def text_matches? item, regexp
    @matches = nil
    return unless text = item[:matched_text]
    @matches = text.match regexp
    @matches.present?
  end

  def get_next_item
    return unless @history.present? && @index < @history.size
    @item = @history[@index]
    @index += 1
  end

  def peek_next_item
    return unless @history.present? && @index < @history.size - 1
    @history[@index]
  end

  def skip_rest_of_history
    @index = @history.size
  end

end
