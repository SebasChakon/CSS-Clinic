# frozen_string_literal: true

class RemoveDoctorVerifiedFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :doctor_verified, :boolean
  end
end
