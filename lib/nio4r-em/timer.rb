module EM
  class Timer
    attr_reader :delay, :next_run, :type
    
    def initialize(delay, type = :once, &block)
      @block = block
      @delay = delay
      @type = type
      
      reset()
    end
    
    def reset(now = Time.now)
      @next_run = now + @delay
    end
    
    def run
      @block.call
    end
    
  end
  
  class <<self
    def add_timer(delay, &block)
      self.timers << Timer.new(delay, :once, &block)
    end
    
    def add_periodic_timer(delay, &block)
      self.timers << Timer.new(delay, :multiple, &block)
    end
    
    def timers
      @timers ||= []
    end
    
    ##
    # Return the maximum time we can sleep
    # before a timer needs action.
    # 
    # @return [Float] number of seconds
    # 
    def delay_before_next_timer_run
      if self.timers.empty?
        nil
      else
        now = Time.now
        # find the first timer to trigger
        t = self.timers.sort_by(&:next_run).first
        [t.next_run - now, 0].max
      end
    end
    
    def check_timers
      now = Time.now
      delete_timers = []
      self.timers.each do |t|
        if now > t.next_run
          t.run()
          t.reset(now)
          delete_timers << t if t.type == :once
        end
      end
      
      @timers = self.timers - delete_timers
      
    end
    
  end
end
