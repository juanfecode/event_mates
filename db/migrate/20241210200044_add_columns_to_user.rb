class AddColumnsToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_name, :string, default: ""
    add_column :users, :last_name, :string, default: ""
    add_column :users, :dob, :date, default: ""
    add_column :users, :phone_number, :string, default: ""
    User.where(first_name: nil).update_all(first_name: "")
    User.where(last_name: nil).update_all(last_name: "")
    User.where(phone_number: nil).update_all(phone_number: "")
    User.where(dob: nil).update_all(dob: "")
  end
end
