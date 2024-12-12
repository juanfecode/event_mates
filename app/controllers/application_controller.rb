class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Allow these fields during sign-up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :dob, :phone_number, :photo])

    # Allow these fields during account updates (e.g., /users/edit)
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :dob, :phone_number, :photo])
  end
  
end
