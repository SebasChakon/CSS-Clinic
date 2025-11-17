# frozen_string_literal: true

require 'test_helper'
class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      firstname: 'Ana',
      lastname: 'Pérez',
      username: 'ANITA123',
      email: "ana_#{SecureRandom.hex(4)}@example.com",
      password: 'password123',
      rol: 'paciente',
      phone: 21_312_312
    )
  end

  test 'usuario válido con todos los atributos' do
    assert_predicate @user, :valid?
  end

  test 'usuario inválido sin email' do
    @user.email = nil

    assert_not @user.valid?
  end

  test 'usuario inválido sin nombre' do
    @user.firstname = nil

    assert_not @user.valid?
  end

  test 'usuario inválido sin contraseña' do
    @user.password = nil

    assert_not @user.valid?
  end

  test 'usuario inválido si el email ya está tomado' do
    @user.save!
    duplicado = User.new(
      firstname: 'Ana',
      lastname: 'Pérez',
      username: 'ANITA123',
      email: @user.email,
      password: 'password123',
      rol: 'paciente',
      phone: 21_312_312
    )

    assert_not duplicado.valid?
  end
end