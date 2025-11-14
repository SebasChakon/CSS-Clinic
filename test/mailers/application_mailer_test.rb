# frozen_string_literal: true

require 'test_helper'

class ApplicationMailerTest < ActiveSupport::TestCase
  test 'hereda de ActionMailer::Base' do
    assert_equal ActionMailer::Base, ApplicationMailer.superclass
  end

  test 'tiene un default from configurado' do
    assert_equal 'from@example.com', ApplicationMailer.default[:from]
  end

  test 'tiene el layout mailer asignado' do
    assert_equal 'mailer', ApplicationMailer._layout
  end

  test 'puede instanciarse correctamente' do
    mailer = ApplicationMailer.new
    assert mailer.is_a?(ApplicationMailer)
  end
end
