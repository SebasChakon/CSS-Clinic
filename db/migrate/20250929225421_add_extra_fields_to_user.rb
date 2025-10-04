class AddExtraFieldsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :phone, :string
    add_column :users, :description, :string
    add_column :users, :photo, :string
  end
end
