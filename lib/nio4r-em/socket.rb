module EM
  class Connection
    attr_accessor :socket
    
    def initialize(*)
      
    end
    
    def peer
      [@socket.peeraddr[3], @socket.peeraddr[1]]
    end
    
    def send_data(data)
      @socket.send(data, 0)
    end
    
  end
  
  class << self
    def start_server(host, port, handler_class_or_module, *args)
      socket = TCPServer.new(host, port)
      
      monitor = self.reactor.register(socket, :r)
      monitor.value = proc do
        handler = build_handler(handler_class_or_module, *args)
        client = socket.accept_nonblock()
        handler.socket = client
        handler.post_init()
        register_reader(client, handler)
      end
    
    end
    
    
    def connect(host, port, handler_class_or_module, *args)
      socket = TCPSocket.new(host, port)
      handler = build_handler(handler_class_or_module, *args)
      
      handler.socket = socket
      handler.post_init()
      register_reader(socket, handler)
    end
    
    
    def build_handler(handler_class_or_module, *args)
      if handler_class_or_module < Connection
        handler_class = handler_class_or_module
      else
        handler_class = Class.new(Connection)
        handler_class.send(:include, handler_class_or_module)
      end
    
      handler_class.new(*args)
    end
    
    def register_reader(socket, handler)
      $n ||= 0
      $n += 1
      
      m = self.reactor.register(socket, :r)
      m.value = proc do
        begin
          data = m.io.read_nonblock(4096)
          handler.receive_data(data)
        rescue EOFError
          handler.unbind
          self.reactor.deregister(socket)
        end
      end
    end
    
  end
  
end
