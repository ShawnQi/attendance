class CreateAttendanceRecords < ActiveRecord::Migration
  def change
    create_table :attendance_records do |t|

      t.date :date, comment: '日期'
      t.integer :date_type, comment: '对应时段'
      t.datetime :sign_in_at, comment: '签到时间'
      t.datetime :sign_out_at, comment: '签退时间'
      t.datetime :late_at, comment: '迟到时间'
      t.datetime :early_at, comment: '早退时间'
      t.boolean :absenteeism_on, null: false, default: false, comment: '是否旷工'
      t.string :overtime, comment: '加班时间'
      t.string :worktime, comment: '工作时间'
      t.boolean :sign_in_on, null: false, default: false, comment: '应签到'
      t.boolean :sign_out_on, null: false, default: false, comment: '应签退'
      t.string :department, comment: '部门'
      t.integer :unit_id, comment: '考勤号id'
      t.integer :lock_version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
