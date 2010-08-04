# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      puts "DEVISE CONTROLER"
      #puts layout
      # "user"
      "users"
    else
      "application"
      puts "NON DEVISE CONTROLER"
    end
  end  
end
