# frozen_string_literal: true

module JsonResponseHelper
  def json_response
    @_json_response ||= JSON.parse(response.body)
  end
end
