class CreateEventTags < ActiveRecord::Migration[7.2]
  def change
    create_table :event_tags do |t|
      t.references :event, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
