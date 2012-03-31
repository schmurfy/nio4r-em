require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter ".*_spec"
    add_filter "/helpers/"
  end
  
end

require 'mocha'
require 'bacon'

Thread.abort_on_exception = true

$LOAD_PATH.unshift( File.expand_path('../../lib/nio4r-em' , __FILE__) )
require 'nio4r-em'
require_relative 'helpers/mocha'
require_relative 'helpers/em_wrapper'

Bacon.summary_on_exit()
