# coding: UTF-8
class Publisher < ActiveRecord::Base
  belongs_to :place
  validates_presence_of :name
  has_paper_trail meta: {change_id: :get_current_change_id}
  include UndoTracker

  attr_accessible :name, :place, :place_id

  def self.import data
    return unless data[:name].present?
    place = Place.import data[:place]
    #publisher = find_or_create_by_name_and_place_id(data[:name], place.id)
    publisher = find_or_create_by(name: data[:name], place_id: place.id)

    raise unless publisher.valid?
    publisher
  end

  def self.import_string string
    parts = Parsers::PublisherParser.parse string
    import parts[:publisher] if parts
  end

  def to_s
    string = place.present? ? "#{place.name}: " : ''
    string << name
  end

  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    joins('LEFT OUTER JOIN places ON place_id = places.id').
      where("CONCAT(COALESCE(places.name, ''), ':', publishers.name) LIKE ?", search_expression).
      map(&:to_s)
  end

end
