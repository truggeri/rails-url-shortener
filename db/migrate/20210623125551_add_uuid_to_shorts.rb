class AddUuidToShorts < ActiveRecord::Migration[6.1]
  def change
    add_column(:shorts, :uuid, :uuid, null: false)
  end
end
