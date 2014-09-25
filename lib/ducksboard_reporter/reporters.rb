module DucksboardReporter
  module Reporters
  end
end

Dir[File.dirname(__FILE__) + '/reporters/*.rb'].each {|file| require file }
