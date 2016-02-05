class TooltipsController < ApplicationController
  before_action :set_tooltip, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_editor
  skip_before_filter :authenticate_editor, only: [:enabled_selectors]

  def index
    tooltips = Tooltip.all
    @grouped_tooltips = tooltips.group_by do |tooltip|
      tooltip.scope
    end
  end

  def show
    @referral=request.referer
  end

  def new
    @tooltip = Tooltip.new(params.permit(:selector))
    @tooltip[:scope] = get_page_from_url(request.referer)
    @referral=request.referer
  end

  def edit
    redirect_to action: :show
  end

  def create
    @tooltip = Tooltip.new(tooltip_params)
    if @tooltip.save
      if params[:referral] && params[:referral].length > 0
        redirect_to params[:referral]     # joe dis broke
      else
        redirect_to tooltip_path(@tooltip), notice: 'Tooltip was successfully created.'
      end
    else
      render :new
    end
  end

  def update


    respond_to do |format|

      if @tooltip.update_attributes tooltip_params

        if params[:referral] && params[:referral].length > 0
          redirect_to params[:referral]
          return
        end

        format.html { redirect_to(@tooltip, notice: 'Tooltip was successfully updated.') }
        format.json { respond_with_bip(@tooltip) }
      else
        format.html { render action: :show }
        format.json { respond_with_bip(@tooltip) }
      end
    end


  end

  def destroy
    @tooltip.destroy
    respond_to do |format|
      format.html { redirect_to tooltips_url, notice: 'Tooltip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def enabled_selectors  # TODO improve this
    scope = get_page_from_url(request.referer)
    json = Tooltip.enabled_selectors.where(scope: scope).pluck(:selector, :text, :id)
    # json=[]
    render json: json # more "json" than json..
  end

  def render_missing_tooltips
    render json: {:show_missing_tooltips => session[:show_missing_tooltips]}
    #render json: {:show_missing_tooltips => current_user.is_superadmin?}
  end

  def toggle_tooltip_helper
    if session[:show_missing_tooltips]
      session[:show_missing_tooltips] = false
    else
      session[:show_missing_tooltips] = true
    end
    redirect_to tooltips_path
  end

  private
  def get_page_from_url url
    unless url
      return nil
    end
    doomed = url.clone
    doomed.slice! root_url
    return doomed.split('/').first

  end
  def set_tooltip
    @tooltip = Tooltip.find params[:id]
  end

  def tooltip_params
    params.require(:tooltip).permit(
        :key, :scope, :text, :key_enabled, :selector, :selector_enabled)
  end


end