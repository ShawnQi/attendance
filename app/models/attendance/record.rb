class Attendance::Record < ActiveRecord::Base
  self.table_name = 'attendance_records'

  belongs_to :unit, class_name: "Attendance::Unit", counter_cache: true

  # 对应时段：白天（1），夜晚（2）
  enum date_type: { day: 1, night: 2 }

end
