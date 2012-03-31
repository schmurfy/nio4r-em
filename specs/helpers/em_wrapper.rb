
module Bacon
  class Context
    def with_eventmachine!
      (class << self; self; end).send(:include, EMSpec)
    end
  end
  
end


module EMSpec # :nodoc:
      
  def wait(timeout = 0.1, &block)
    @timeout_interval = timeout
    @end_check = block
  end
  alias wait! wait

  ##
  # Indicates that an async spec is finished. See +wait+ for example usage.
  def done
    @end_check.call if @end_check
    EM.cancel_timer(@timeout)
    EM.stop
  end
  alias done! done
  
  def create_timeout_timer(delay = 0.1)
    EM::add_timer(delay){ done! }
  end
  
  def describe(*, &block)
    super do
      with_eventmachine!
      block.call
    end
  end
  
  def it(description, &block) # :nodoc:
    raise "block required" unless block

    super do
      @timeout_interval = nil

      EM.run do
        @timeout = create_timeout_timer()

        instance_eval(&block)
      
        if @timeout_interval
          EM::cancel_timer(@timeout)
          @timeout = create_timeout_timer(@timeout_interval)
        else
          done!
        end
        
      end
    end
  end

end
