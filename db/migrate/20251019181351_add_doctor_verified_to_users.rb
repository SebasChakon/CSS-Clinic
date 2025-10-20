class AddDoctorVerifiedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :doctor_verified, :boolean, null: false, default: false
  end
end

