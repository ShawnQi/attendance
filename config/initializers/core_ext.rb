class String

  def is_date?
    begin
      Date.parse(self)
      true
    rescue
      false
    end
  end

  def is_datetime?
    begin
      Datetime.parse(self)
      true
    rescue
      false
    end
  end

end


class Array
  def clip n=1
    take size - n
  end
end


class Float

  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end

  def ceil_to(x)
    (self * 10**x).round(2).ceil.to_f / 10**x
  end

  def floor_to(x)
    (self * 10**x).floor.to_f / 10**x
  end

end
