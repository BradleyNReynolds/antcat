FactoryBot.define do
  factory :taxon do
    protonym
    valid

    trait :valid do
      status { Status::VALID }
    end

    trait :synonym do
      status { Status::SYNONYM }
      with_current_valid_taxon
    end

    trait :homonym do
      status { Status::HOMONYM }
    end

    trait :original_combination do
      status { Status::ORIGINAL_COMBINATION }
      with_current_valid_taxon
    end

    trait :unidentifiable do
      status { Status::UNIDENTIFIABLE }
    end

    trait :unavailable do
      status { Status::UNAVAILABLE }
    end

    trait :excluded_from_formicidae do
      status { Status::EXCLUDED_FROM_FORMICIDAE }
    end

    trait :fossil do
      fossil { true }
    end

    trait :with_current_valid_taxon do
      current_valid_taxon { Family.first || FactoryBot.create(:family) }
    end

    factory :family, class: Family do
      association :name, factory: :family_name
    end

    factory :subfamily, class: Subfamily do
      association :name, factory: :subfamily_name
    end

    factory :tribe, class: Tribe do
      association :name, factory: :tribe_name
      subfamily
    end

    factory :genus, class: Genus do
      association :name, factory: :genus_name
      tribe
      subfamily { |a| a.tribe && a.tribe.subfamily }
    end

    factory :subgenus, class: Subgenus do
      association :name, factory: :subgenus_name
      genus
    end

    factory :species, class: Species do
      association :name, factory: :species_name
      genus
    end

    factory :subspecies, class: Subspecies do
      association :name, factory: :subspecies_name
      species
      genus
    end

    trait :old do
      association :taxon_state, review_state: TaxonState::OLD
    end

    trait :waiting do
      association :taxon_state, review_state: TaxonState::WAITING
    end

    trait :approved do
      association :taxon_state, review_state: TaxonState::APPROVED
    end
  end
end

def create_genus name_string, attributes = {}
  attributes = attributes.reverse_merge(name: create(:genus_name, name: name_string))
  FactoryBot.create :genus, attributes
end

def create_species name_string, attributes = {}
  attributes = attributes.reverse_merge(name: create(:species_name, name: name_string))
  FactoryBot.create :species, attributes
end

def create_subspecies name_string, attributes = {}
  attributes = attributes.reverse_merge(name: create(:subspecies_name, name: name_string))
  FactoryBot.create :subspecies, attributes
end