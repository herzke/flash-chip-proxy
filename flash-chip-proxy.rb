require 'socket'
require 'digest'

class FlashChipProxySettings

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

  attr_accessor :port
  
  def initialize(storage_directory = ".", port = 8880)
    self.mode = :replace
    self.storage_directory = storage_directory
    self.port = port
    open_port()
  end

  def open_port()
    # derived class will do:
    # @acceptor = TCPServer.open(port())
  end
end

class FlashChipProxy < FlashChipProxySettings
  def open_port()
    @acceptor = TCPServer.open(port())
    @thread = Thread.new{acceptor_loop()}
  end
  def acceptor_loop()
    loop do
      socket = @acceptor.accept()
      request = ""
      line = ""
      while request !~ /\r\n\r\n/
        line = socket.sysread(1000)
        request = request + line
      end
      request = request.sub(/\r\n\r\n.*/m, "\r\n\r\n")
      md5=Digest::MD5.hexdigest(request)
      if mode() == :replace
        socket.write(IO.read(File.join(storage_directory(), md5)))
        socket.close()
      end
    end
  end
end
