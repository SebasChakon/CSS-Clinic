require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
end

puts "→ SimpleCov iniciado, generando reporte de cobertura…"

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# === Aquí empieza la clase base para los tests ===
class ActiveSupport::TestCase
  # Incluye los helpers de Devise para que funcione sign_in / sign_out
  include Devise::Test::IntegrationHelpers

  # Si tienes otros helpers globales para los tests, puedes ponerlos aquí también
  # Ejemplo:
  # fixtures :all
end
