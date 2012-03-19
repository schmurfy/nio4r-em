require "nio4r-em/version"
require 'nio'
require 'socket'

require File.expand_path('../nio4r-em/timer', __FILE__)
require File.expand_path('../nio4r-em/socket', __FILE__)

module EM  
  class <<self
    
    attr_accessor :reactor
    
    def run
      @running = true
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
    
  end
end

