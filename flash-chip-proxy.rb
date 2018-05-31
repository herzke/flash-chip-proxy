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

  attr_reader :storage_directory
  def storage_directory=(directory)
    if File.directory?(directory)
      @storage_directory = directory
    else
      raise "directory #{directory} does not exist"
    end
  end

  def initialize(storage_directory = ".")
    self.mode = :replace
    self.storage_directory = storage_directory
  end

end
