require_relative '../spec_helper'

describe 'Timers' do
  with_eventmachine!
  
  describe 'one-shot timer' do
    should 'trigger on time' do
      start_at = Time.now
      triggered_at = nil
      
      EM::add_timer(0.01){ triggered_at = Time.now }
      EM::add_timer(0.1) do
        triggered_at.should != nil
        (triggered_at - start_at).should.be.close(0.01, 0.01)
      end
      
      wait(0.2)
    end
  end
  
  describe 'periodic timer' do
    should 'trigger on time' do
      triggered_at = [Time.now]
      
      t = EM::add_periodic_timer(0.01){ triggered_at << Time.now }
      EM::add_timer(0.1) do
        EM::cancel_timer(t)
        triggered_at.size.should == 10
        
        1.upto(triggered_at.size - 1) do |n|
          triggered_at[n-1].should != nil
          triggered_at[n].should != nil
          (triggered_at[n] - triggered_at[n-1]).should.be.close(0.01, 0.01)
        end
      end
      
      wait(0.2)
    end
  end
  
end
