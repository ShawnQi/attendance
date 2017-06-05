class CreateAttendanceUnits < ActiveRecord::Migration
  def change
    create_table :attendance_units do |t|

      t.integer :number
      t.integer :user_id
      t.integer :records_count, null: false, default: 0
      t.integer :lock_version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
