class AddCostToShort < ActiveRecord::Migration[6.1]
  def change
    add_column(:shorts, :cost, :integer, null: false)
  end
end
