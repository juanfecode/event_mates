class CreateGroupMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :group_messages do |t|
      t.text :message
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
