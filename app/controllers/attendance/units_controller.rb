class Attendance::UnitsController < ApplicationController

  def index
    @unit = Attendance::Unit.first
  end

  def import
    Dir["#{Rails.root}/public/201705/*.xlsx"].each do |file|
      workbook = RubyXL::Parser.parse(file)
      worksheet = workbook[0]
      database_transaction do
        worksheet.each_with_index do |row,_index|
          date = row.cells[5].value.to_date if row.cells[5] && row.cells[5].value.is_date? # 日期
          if _index != 0 && date && ![0,6].include?(date.wday) # 表头不要，没有日期不要，周六周天不要
            record = ::Attendance::Record.new
            cell = row.cells
            unit = ::Attendance::Unit.find_or_create_by(number: cell[1].value.to_i) if cell[1] && cell[1].value
            record.unit_id = unit.id if unit # 考勤号
            record.date = date
            record.date_type = get_date_type(cell[6].value) if cell[6] && cell[6].value # 对应时段
            record.sign_in_at = datetime_from_date_and_time(date,cell[9].value) if cell[9] && cell[9].value # 签到时间
            record.sign_out_at = datetime_from_date_and_time(date,cell[10].value) if cell[10] && cell[10].value # 签退时间
            record.late_at = datetime_from_date_and_time(date,cell[13].value) if cell[13] && cell[13].value # 迟到时间
            record.early_at = datetime_from_date_and_time(date,cell[14].value) if cell[14] && cell[14].value # 早退时间
            record.absenteeism_on = cell[15].value=='True' ? true : false if cell[15] && cell[15].value # 是否旷工
            record.overtime = cell[16].value if cell[16] && cell[16].value # 加班时间
            record.worktime = cell[17].value if cell[17] && cell[17].value # 工作时间
            record.sign_in_on = cell[19].value=='True' ? true : false if cell[19] && cell[19].value # 应签到
            record.sign_out_on = cell[20].value=='True' ? true : false if cell[20] && cell[20].value # 应签退
            record.department = cell[21].value if cell[21] && cell[21].value # 应签退
            record.save!
          end
        end
      end
    end
    redirect_to attendance_units_path
  end

  def export
    workbook = RubyXL::Parser.parse("#{Rails.root}/考勤表.xlsx")
    worksheet = workbook[0]
    time = '2017-05-01'.to_date
    (time.beginning_of_month..time.end_of_month).to_a.each_with_index{|date,_index|
      # 事例表要求，去除前2列表格式
      worksheet[2][(2+_index)*2-1].change_contents(date.to_s, worksheet[2][(2+_index)*2-1].formula)
      worksheet[3][(2+_index)*2-1].change_contents('上班')
      worksheet[3][(2+_index)*2].change_contents('下班')
    }
    worksheet.each_with_index do |row,row_index|
      # 事例表要求，去除前4行表格式
      unless (0..3).to_a.include?(row_index)
        user = ::User.find_by_name(row.cells[2].value) if row && row.cells[2] && row.cells[2].value # 查找用户
        if user
          (time.beginning_of_month..time.end_of_month).to_a.each_with_index do |date,_index|
            record = user.unit.records.where(date: date).first
            sign_in_at = record.try(:sign_in_at)
            sign_out_at = record.try(:sign_out_at)
            if sign_in_at.present?
              worksheet[row_index][(2+_index)*2-1].change_contents(format_sign_time(sign_in_at))
              # 迟到，超过09:10
              worksheet.sheet_data[row_index][(2+_index)*2-1].change_fill('FF0000') if sign_in_at >= sign_in_at.change(hour: 9, min: 10)
            else
              # 缺勤，标灰
              worksheet.sheet_data[row_index][(2+_index)*2-1].change_fill('585858')
            end
            if sign_out_at.present?
              worksheet[row_index][(2+_index)*2].change_contents(format_sign_time(sign_out_at))
              # 早退，早于18:00
              worksheet.sheet_data[row_index][(2+_index)*2].change_fill('FF0000') if sign_out_at < sign_out_at.change(hour: 18, min: 0)
            else
              # 缺勤，标灰
              worksheet.sheet_data[row_index][(2+_index)*2].change_fill('585858')
            end
          end
        end
      end
    end
    workbook.write("#{Rails.root}/2017年5月.xlsx")
    redirect_to attendance_units_path
  end

  private

    def get_date_type date_type
      case date_type
      when '白天' then 1
      when '夜晚' then 2
      else nil
      end
    end

    def format_sign_time time
      return '' unless time.present? && time.is_a?(Time)
      time.to_s(:time)
    end

end
