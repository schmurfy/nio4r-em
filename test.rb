
mode = ARGV[0] || 'nio'

if mode == 'em'
  puts "Using EventMachine"
  require 'eventmachine'
else
  puts "Using NIO"
  require 'rubygems'
  require 'bundler/setup'
  require 'nio4r-em'  
end

trap('INT'){ EM::stop() }

Thread.abort_on_exception = true

def assert(what)
  unless what
    raise "Assertion failed"
  end
end

module Handler
  
  def post_init
    puts "[S] connected"
  end
  
  def receive_data(data)
    puts "[S] received: #{data}"
    send_data("re: #{data}")
  end
  
  def unbind
    puts "[S] disconnected"
  end
end

class ClientHandler < EM::Connection
  def initialize(n)
    @n = n
  end
  
  def post_init
    puts "[C#{@n}] connected"
    receive_data(nil)
  end
  
  def receive_data(data)
    puts "[C#{@n}] received: #{data}"
    EM::add_timer(1) do
      send_data("ping")
      puts "[C#{@n}] ping sent"
    end
  end
  
  def unbind
    puts "[C#{@n}] disconnected"
  end
  
end


EM::run do
  EM::start_server('0.0.0.0', 4000, Handler, 42)
  
  EM::connect('127.0.0.1', 4000, ClientHandler, 1)
  EM::connect('127.0.0.1', 4000, ClientHandler, 2)
  EM::connect('127.0.0.1', 4000, ClientHandler, 3)
  
  puts "Reactor thread: #{'%#x' % EM::reactor_thread.object_id}"
  
  assert EM::reactor_thread?
  
  Thread.new do
    assert !EM::reactor_thread?
  end
  
  n = 0
  EM::add_periodic_timer(1) do
    puts "tick: #{n += 1}"
  end
  
  EM::add_timer(2) do
    puts "ONCE !"
  end
  
  EM::add_periodic_timer(0.2){ puts "speedy !" }
  
end
