# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return unless current_user.paciente?

    @farmacias = if session[:ultimas_farmacias] && session[:ultima_ubicacion]
                   session[:ultimas_farmacias]
                 else
                   []
                 end
  end

  def unregistered; end
end
