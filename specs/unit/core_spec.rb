require_relative '../spec_helper'

describe 'Reactor' do  
  with_eventmachine!
  
  it 'can identify reactor thread' do    
    EM::reactor_thread.should == Thread.current
    EM::reactor_thread?.should == true
    
    Thread.new do
      EM::reactor_thread.should != Thread.current
      EM::reactor_thread?.should == false
    end.join
  end
  
  it 'can be stopped' do
    EM::reactor_running?.should == true
    EM::stop
    EM::reactor_running?.should == false
  end
  
end
