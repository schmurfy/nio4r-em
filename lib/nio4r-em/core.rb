module EM  
  class <<self
    
    attr_accessor :reactor, :reactor_thread
    
    def run
      @running = true
      @reactor_thread = Thread.current
      self.reactor = NIO::Selector.new
      yield
      
      while @running
        reactor.select(delay_before_next_timer_run) do |m|
          m.value.call
        end
        check_timers()
      end
      
    end
    
    def stop
      @running = false
    end
    
    def reactor_running?
      !!@running
    end
    
    def reactor_thread?
      Thread.current == @reactor_thread
    end
    
  end
end
