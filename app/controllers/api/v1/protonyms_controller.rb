module Api::V1
  class ProtonymsController < Api::ApiController


    def index
      protonyms = Protonym.all
      render json: protonyms, status: :ok
    end


    def show
      super Protonym
    end
  end
end