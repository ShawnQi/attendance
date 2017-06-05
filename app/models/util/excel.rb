class Util::Excel

  def open file
    begin
      RubyXL::Parser.parse(file.path)
    rescue ExceptionName => e
      Rails.logger.error "gem RubyXL error #{e}"
    end
  end

end
