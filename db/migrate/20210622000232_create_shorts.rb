class CreateShorts < ActiveRecord::Migration[6.1]
  def change
    create_table(:shorts, if_not_exists: true) do |t|
      t.string  :short_url,      null: false
      t.string  :full_url,       null: false
      t.boolean :user_generated, null: false, default: false
      t.timestamps
    end

    add_index(:shorts, :short_url)
  end
end
