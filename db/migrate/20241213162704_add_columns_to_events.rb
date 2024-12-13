class AddColumnsToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :link, :string
    add_column :events, :address, :string
  end
end
