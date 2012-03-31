require_relative '../spec_helper'
require 'sockets'

describe 'Socket' do
  with_eventmachine!
  
  before do
    @handler_class = Class.new(EM::Connection)
  end
  
  describe 'A TCP server' do
    
    should 'call post_init on connect' do
      @handler_class.any_instance.expects(:post_init)
      @handler_class.any_instance.expects(:unbind)
      EM::start_server('127.0.0.1', 50000, @handler_class)
          
      Thread.new do
        cl = TCPSocket.new('127.0.0.1', 50000)
        cl.close
      end
          
      wait
    end
    
    should 'call receive_data on data' do
      @handler_class.any_instance.expects(:post_init)
      @handler_class.any_instance.expects(:receive_data).with("PAYLOAD")
      @handler_class.any_instance.expects(:unbind)
      
      EM::start_server('127.0.0.1', 50001, @handler_class)
          
      Thread.new do
        cl = TCPSocket.new('127.0.0.1', 50001)
        cl.send("PAYLOAD", 0)
        cl.close
      end
          
      wait
      
    end
  
  end
  
  
  describe 'A TCP Client' do
    it 'can connects and send data to a server' do
      server = TCPServer.new('127.0.0.1', 50002)
      Thread.new do
        cl = server.accept
        sleep(0.1)
        cl.should.not == nil
        data = cl.read_nonblock(100)
        data.should == "HELLO"
        cl.close
        server.close
        done
      end
    
      s = EM::connect('127.0.0.1', 50002)
      s.send_data('HELLO')
      
      wait(0.2)
    end
    
    it 'can use a module as handler' do
      comm_completed = false
      spec = self
      
      handler_module = Module.new do
        def post_init
          send_data 'HELLO'
        end
        
        define_method(:receive_data) do |data|
          data.should == "WELCOME"
          comm_completed = true
          spec.done!
        end
      end
      
      server = TCPServer.new('127.0.0.1', 50003)
      Thread.new do
        cl = server.accept
        sleep(0.1)
        cl.should.not == nil
        data = cl.read_nonblock(100)
        data.should == "HELLO"
        cl.send("WELCOME", 0)
        sleep(0.1)
        cl.close
        server.close
      end
      
      EM::connect('127.0.0.1', 50003, handler_module)
      
      wait(2) do
        comm_completed.should == true
      end
    end
    
  end
  
end
