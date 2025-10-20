class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    extra_attrs = [:username, :firstname, :lastname, :phone, :description, :photo, :rol]

    devise_parameter_sanitizer.permit(:sign_up, keys: extra_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_attrs)
  end

  private
  def ensure_verified_doctor!
    if current_user.doctor? && !current_user.doctor_verified?
      redirect_to root_path, alert: "Tu cuenta aún no ha sido verificada por un administrador."
    end
    return unless current_user&.doctor?

    unless current_user.doctor_verified?
      redirect_to root_path, alert: "Tu cuenta aún no ha sido verificada por un administrador."
    end
  end


end