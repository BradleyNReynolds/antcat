class DefaultReferencesController < ApplicationController
  def update
    DefaultReference.set session, Reference.find(params[:id])
    if request.xhr?
      render nothing: true
    else
      redirect_to latest_additions_references_path
    end
  end
end