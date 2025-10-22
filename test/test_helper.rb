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
