
This gem is just an experimentation for now, its goal is to provide a gateway to run eventmachine
code with nio4r.

There is currently no tests but you can check the test.rb which I use to check that the code/behavior
is the same when using EM and nio4r.

For now the basic calls are there:

## Core

- EM::reactor_thread
- EM::reactor_thread?
- EM::run
- EM::stop

## Sockets

- EM::run
- EM::start_server
- EM::connect

The two EM ways are supported for handlers: module and class inheriting from EM::Connection.


## Timers

- EM::add_timer
- EM::add_periodic_timer
- EM::cancel_timer

