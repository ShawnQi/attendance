class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def datetime_from_date_and_time date,time
    return nil unless date.is_a?(Date) && time.present?
    date.to_datetime + Time.parse(time).seconds_since_midnight.seconds
  end

  def database_transaction
    begin
      ActiveRecord::Base.transaction do
        yield
      end
      true
    rescue => e
      logger.error %[#{e.class.to_s} (#{e.message}):\n\n #{e.backtrace.join("\n")}\n\n]
      false
    end
  end

end
