class ConvertToSubspeciesController < ApplicationController
  before_action :ensure_can_edit_catalog
  before_action :set_taxon, only: [:new, :create]

  def new
  end

  # TODO move validations to service.
  def create
    unless @taxon.is_a? Species
      @taxon.errors.add :base,
        "Taxon to be converted to a subspecies must be of rank species."
      render :new and return
    end

    if @taxon.subspecies.present?
      @taxon.errors.add :base, <<-MSG
        This species has subspecies of its own,
        so it can't be converted to a subspecies
      MSG
      render :new and return
    end

    if params[:new_species_id].blank?
      @taxon.errors.add :base, 'Please select a species.'
      render :new and return
    end

    @new_species = Taxon.find(params[:new_species_id])

    unless @new_species.is_a? Species
      @taxon.errors.add :base, "The new parent must be of rank species."
      render :new and return
    end

    # TODO allow moving to incerae sedis genera
    unless @new_species.genus
      @taxon.errors.add :base, "The new parent must have a genus."
      render :new and return
    end

    unless @new_species.genus == @taxon.genus
      @taxon.errors.add :base, "The new parent must be in the same genus."
      render :new and return
    end

    begin
      @taxon.convert_to_subspecies_of @new_species
    rescue Taxon::TaxonExists => e
      @taxon.errors.add :base, e.message
      render :new and return
    end

    redirect_to catalog_path(@taxon),
      notice: "Probably converted species to a subspecies."
  end

  private

    def set_taxon
      @taxon = Taxon.find(params[:taxa_id])
    end
end
