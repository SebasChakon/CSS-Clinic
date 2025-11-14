class HomeController < ApplicationController
  def index
    if current_user.paciente?
      if session[:ultimas_farmacias] && session[:ultima_ubicacion]
        @farmacias = session[:ultimas_farmacias]
      else
        @farmacias = []
      end
    end
  end

  def unregistered; end
end
