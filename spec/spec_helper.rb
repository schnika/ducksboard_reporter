require "bundler/setup"
Bundler.setup

require "ducksboard_reporter"

DucksboardReporter.logger.level = Logger::FATAL

RSpec.configure do |config|
    # some (optional) config here
end
