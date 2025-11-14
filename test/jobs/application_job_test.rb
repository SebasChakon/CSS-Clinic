# frozen_string_literal: true

require 'test_helper'

class ApplicationJobTest < ActiveJob::TestCase
  test 'hereda de ActiveJob::Base' do
    assert_equal ActiveJob::Base, ApplicationJob.superclass
  end

  test 'puede instanciarse correctamente' do
    job = ApplicationJob.new
    assert_instance_of ApplicationJob, job
  end

  test 'puede encolarse sin errores' do
    assert_enqueued_with(job: ApplicationJob) do
      ApplicationJob.perform_later
    end
  end
end
