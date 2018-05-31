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

  attr_accessor :storage_directory
  
  def initialize(storage_directory = ".")
    self.mode = :replace
    self.storage_directory = storage_directory
  end

end
