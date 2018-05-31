class FlashChipProxy

  attr_reader(:mode)
  def mode=(operating_mode)
    if (operating_mode == :learn || operating_mode == :replace)
      @mode = operating_mode
    else
      raise "operating_mode has to be :learn or :replace, was " +
            operating_mode.inspect()
    end
  end

  def storage_directory() "." end
  
  def initialize()
    self.mode = :replace
  end

end
