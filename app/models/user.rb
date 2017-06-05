class User < ActiveRecord::Base
  self.table_name = 'users'

  has_one :unit, class_name: "Attendance::Unit"

end
