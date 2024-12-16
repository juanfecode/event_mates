class ChangeBioToTextInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :bio, :text
  end
end
