# frozen_string_literal: true

require "test_helper"

class ReservasHelperTest < ActionView::TestCase
  test "devuelve la clase correcta para :pendiente" do
    assert_equal "bg-yellow-100 text-yellow-800",
                 estado_badge_class(:pendiente)
  end

  test "devuelve la clase correcta para 'pendiente' (string)" do
    assert_equal "bg-yellow-100 text-yellow-800",
                 estado_badge_class("pendiente")
  end

  test "devuelve la clase correcta para :confirmada" do
    assert_equal "bg-blue-100 text-blue-800",
                 estado_badge_class(:confirmada)
  end

  test "devuelve la clase correcta para :cancelada" do
    assert_equal "bg-red-100 text-red-800",
                 estado_badge_class(:cancelada)
  end

  test "devuelve la clase correcta para :completada" do
    assert_equal "bg-green-100 text-green-800",
                 estado_badge_class(:completada)
  end

  test "devuelve clase genérica para estado desconocido" do
    assert_equal "bg-gray-100 text-gray-800",
                 estado_badge_class(:otro)
  end
end
