class ApplicationController < ActionController::Base
  
  skip_before_action :verify_authenticity_token
  def check
    render html: "bhature with lassi"
  end


end
