class SetDefaultToRequest < ActiveRecord::Migration[7.2]
  def change
    change_column_default :requests, :status, "pending"
    Request.where(status: nil).update_all(status: "pending")
  end
end
