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

  def learn_from(remote_host, remote_port = 80)
    self.mode=:learn
    @remote_host = remote_host
    @remote_port = remote_port
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
      handle_connection(socket)
    end
  end

  def handle_connection(connection)
    request = read_request(connection)
    md5=Digest::MD5.hexdigest(request)
    cache_file = File.join(storage_directory(), md5)
    if mode() == :replace
      serve_from_cache(connection, request, cache_file)
    else
      serve_from_remote_and_store(connection, request, cache_file)
    end
    connection.close()
  end

  def serve_from_cache(connection, request, cache_file)
    connection.write(IO.read(cache_file))
  end

  def serve_from_remote_and_store(client, request, cache_file)
    server = TCPSocket.open(@remote_host, @remote_port)
    server.write(request)
    if File.exist(cache_file)
      File.rename(cache_file, cache_file + ".old")
    end
    file = File.open(cache_file, "w")
    data = ""
    begin
      loop do
        data = server.sysread(1000)
        client.write(data)
        file.write(data)
        data = ""
      end
    rescue EOFError, SystemCallError
    end
    server.close()
    file.close()
  end
  
  def read_request(connection)
    request = ""
    while request !~ /\r\n\r\n/
      line = connection.sysread(1000)
      request = request + line
    end
    request = request.sub(/\r\n\r\n.*/m, "\r\n\r\n")
    return request
  end
end
