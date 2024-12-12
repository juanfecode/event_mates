class AddMessageColumnToRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :requests, :message, :string, default: ""
    Request.where(message: nil).update_all(message: "")
  end
end
