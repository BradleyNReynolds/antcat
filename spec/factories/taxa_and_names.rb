# TODO this creates too many objects and it seems to create new associations
# even when it's passed existing objects.
#
# Creating a taxon of a lower rank creates all the taxa above it as specified
# by the factories. This also create objects for their dependencies, such
# as the protonym, which in turn creates a new citation --> another reference
# --> another author --> etc etc = many objects.

FactoryGirl.define do
  factory :name do
    sequence(:name) { |n| raise }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :family_name do
    name 'Formicidae'
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :subfamily_name do
    sequence(:name) { |n| "Subfamily#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :tribe_name do
    sequence(:name) { |n| "Tribe#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :subtribe_name do
    sequence(:name) { |n| "Subtribe#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :genus_name do
    sequence(:name) { |n| "Genus#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name }
    epithet_html { "<i>#{name}</i>" }
  end

  # TODO possibly broken
  # from prod db
  # Subgenus.first.name.name_html # "<i>Lasius</i> <i>(Acanthomyops)</i>"
  #
  # from
  # $rails console test --sandbox
  # SunspotTest.stub
  # FactoryGirl.create :subgenus
  # Subgenus.first.name.name_html # "<i>Atta</i> <i>(Atta (Subgenus2))</i>"
  factory :subgenus_name do
    sequence(:name) { |n| "Atta (Subgenus#{n})" }
    name_html { "<i>Atta</i> <i>(#{name})</i>" }
    epithet { name.split(' ').last }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :species_name do
    sequence(:name) { |n| "Atta species#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name.split(' ').last }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :subspecies_name do
    sequence(:name) { |n| "Atta species subspecies#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name.split(' ').last }
    epithets { name.split(' ')[-2..-1].join(' ') }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :taxon do
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    protonym
    status 'valid'
  end

  factory :family do
    association :name, factory: :family_name
    association :type_name, factory: :genus_name
    protonym
    status 'valid'
  end

  factory :subfamily do
    association :name, factory: :subfamily_name
    association :type_name, factory: :genus_name
    protonym
    status 'valid'
  end

  factory :tribe do
    association :name, factory: :tribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status 'valid'
  end

  # FIX? Broken. The are 8 SubtribeName:s in the prod db, but no
  # Subtribe:s, so low-priority.
  factory :subtribe do
    association :name, factory: :subtribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status 'valid'
  end

  factory :genus do
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    tribe
    subfamily { |a| a.tribe && a.tribe.subfamily }
    protonym
    status 'valid'
  end

  factory :subgenus do
    association :name, factory: :subgenus_name
    association :type_name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :species_group_taxon do
    association :name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :species do
    association :name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :subspecies do
    association :name, factory: :species_name
    species
    genus
    protonym
    status 'valid'
  end
end

# TODO probably remove and use this name for `#create_taxon_object`.
def create_taxon name_or_attributes = 'Atta', attributes = {}
  create_taxon_object name_or_attributes, :genus, attributes
end

def create_family
  create_taxon_object 'Formicidae', :family
end

def create_subfamily name_or_attributes = 'Dolichoderinae', attributes = {}
  create_taxon_object name_or_attributes, :subfamily, attributes
end

def create_tribe name_or_attributes = 'Attini', attributes = {}
  create_taxon_object name_or_attributes, :tribe, attributes
end

def create_genus name_or_attributes = 'Atta', attributes = {}
  create_taxon_object name_or_attributes, :genus, attributes
end

def create_subgenus name_or_attributes = 'Atta (Subatta)', attributes = {}
  create_taxon_object name_or_attributes, :subgenus, attributes
end

def create_species name_or_attributes = 'Atta major', attributes = {}
  create_taxon_object name_or_attributes, :species, attributes
end

def create_subspecies name_or_attributes = 'Atta major minor', attributes = {}
  create_taxon_object name_or_attributes, :subspecies, attributes
end

def create_taxon_object name_or_attributes, rank, attributes = {}
  taxon_factory = rank
  name_factory = "#{rank}_name".to_sym

  attributes =
    if name_or_attributes.kind_of? String
      name, epithet, epithets = get_name_parts name_or_attributes
      name_object = create name_factory, name: name, epithet: epithet, epithets: epithets
      attributes.reverse_merge name: name_object, name_cache: name
    else
      name_or_attributes
    end

  build_stubbed = attributes.delete :build_stubbed
  build = attributes.delete :build
  build_stubbed ||= build
  FactoryGirl.send(build_stubbed ? :build_stubbed : :create, taxon_factory, attributes)
end

def get_name_parts name
  parts = name.split ' '
  epithet = parts.last
  epithets = parts[1..-1].join(' ') unless parts.size < 2
  return name, epithet, epithets
end

def find_or_create_name name
  name, epithet, epithets = get_name_parts name
  create :name, name: name, epithet: epithet, epithets: epithets
end

def create_species_name name
  name, epithet, epithets = get_name_parts name
  create :species_name, name: name, epithet: epithet, epithets: epithets
end

def create_subspecies_name name
  name, epithet, epithets = get_name_parts name
  create :subspecies_name, name: name, epithet: epithet, epithets: epithets
end

def create_synonym senior, attributes = {}
  junior = create_genus attributes.merge status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end

def create_taxon_version_and_change review_state, user = @user, approver = nil, genus_name = 'default_genus'
  name = create :name, name: genus_name
  taxon = create :genus, name: name
  taxon.taxon_state.review_state = review_state

  change = create :change, user_changed_taxon_id: taxon.id, change_type: "create"
  create :version, item_id: taxon.id, whodunnit: user.id, change_id: change.id

  if approver
    change.update_attributes! approver: approver, approved_at: Time.now
  end

  taxon
end

# New set of light factories because FactoryGirl does too much and some factories are bugged.
# TODO refactor and merge.
def build_minimal_family
  name = FamilyName.new name: "Formicidae"
  protonym = Protonym.first || minimal_protonym
  Family.new name: name, protonym: protonym
end

def minimal_family
  build_minimal_family.tap &:save
end

def minimal_subfamily
  name = SubfamilyName.new name: "Minimalinae"
  protonym = Protonym.first || minimal_protonym
  Subfamily.new(name: name, protonym: protonym).tap &:save
end

def minimal_protonym
  reference = UnknownReference.new citation: "book", citation_year: 2000, title: "Ants plz"
  citation = Citation.new reference: reference
  name = Name.new name: "name"

  Protonym.new name: name, authorship: citation
end

def an_old_taxon
  taxon = minimal_family
  taxon.taxon_state.update_columns review_state: :old
  taxon.reload
  taxon
end

def old_family_and_subfamily
  family = an_old_taxon

  subfamily = minimal_subfamily
  subfamily.family = family
  subfamily.save
  subfamily.taxon_state.update_columns review_state: :old
  subfamily.reload

  # Confirm.
  expect(family).to be_old
  expect(subfamily.family).to eq family
  expect(subfamily).to be_old

  [family, subfamily]
end

def mark_as_auto_generated objects
  Array.wrap(objects)
    .each { |object| object.update_columns auto_generated: true }
    .each { |object| expect(object).to be_auto_generated }
end
