# frozen_string_literal: true

class ReferenceSectionsController < ApplicationController
  PER_PAGE_OPTIONS = [30, 100]

  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :ensure_user_is_editor, only: [:destroy]

  def index
    @reference_sections = ReferenceSection.all
    @reference_sections = @reference_sections.joins(:taxon).where(taxa: { type: params[:taxon_type] }) if params[:taxon_type].present?
    @reference_sections = @reference_sections.search(params[:q], params[:search_type]) if params[:q].present?
    @reference_sections = @reference_sections.includes(taxon: [:name]).paginate(page: params[:page], per_page: per_page)
  end

  def show
    @reference_section = find_reference_section
  end

  def new
    @taxon = find_taxon
    @reference_section = @taxon.reference_sections.new
  end

  def create
    @taxon = find_taxon
    @reference_section = @taxon.reference_sections.new(reference_section_params)

    if @reference_section.save
      @reference_section.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to edit_taxa_path(@reference_section.taxon), notice: "Successfully added reference section."
    else
      render :new
    end
  end

  def edit
    @reference_section = find_reference_section
  end

  def update
    @reference_section = find_reference_section

    updated = @reference_section.update(reference_section_params)

    if updated
      @reference_section.create_activity :update, current_user, edit_summary: params[:edit_summary]
    end

    respond_to do |format|
      format.json { render_json @reference_section }
      format.html do
        if updated
          redirect_to catalog_path(@reference_section.taxon), notice: "Successfully updated reference section."
        else
          render :edit
        end
      end
    end
  end

  def destroy
    reference_section = find_reference_section

    reference_section.destroy!
    reference_section.create_activity :destroy, current_user, edit_summary: params[:edit_summary]

    respond_to do |format|
      format.json do
        render json: { success: true }
      end
      format.html do
        redirect_to catalog_path(reference_section.taxon), notice: "Successfully deleted reference section."
      end
    end
  end

  private

    def find_taxon
      Taxon.find(params[:taxa_id])
    end

    def find_reference_section
      ReferenceSection.find(params[:id])
    end

    def reference_section_params
      params.require(:reference_section).permit(:references_taxt, :subtitle_taxt, :title_taxt)
    end

    def per_page
      params[:per_page] if params[:per_page].to_i <= PER_PAGE_OPTIONS.max
    end

    def render_json reference_section
      render json: {
        content: render_to_string(partial: 'reference_sections/taxt_editor_template', locals: { reference_section: reference_section }),
        error: reference_section.errors.full_messages.to_sentence
      }
    end
end
