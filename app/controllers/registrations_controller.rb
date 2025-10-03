class RegistrationsController < Devise::RegistrationsController

  def sign_up_params
    params.require(:user).permit(:email,:password,:password_confirmation,:username,:firstname,:lastname,:phone,:description,:photo,:rol)
  end 
end
