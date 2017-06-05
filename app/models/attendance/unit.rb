class Attendance::Unit < ActiveRecord::Base
  self.table_name = 'attendance_units'

  has_many :records, class_name: "Attendance::Record"


end
