class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      t.string :name
      t.integer :units_count, null: false, default: 0
      t.integer :lock_version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
