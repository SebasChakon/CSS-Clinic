class RegistrationsController < Devise::RegistrationsController

  def sign_up_params
    params.require(:user).permit(:email,:password,:password_confirmation,:username,:firstname,:lastname,:phone,:description,:avatar,:rol)
  end 
end
