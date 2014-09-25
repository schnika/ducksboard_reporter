require "rubygems"
require "bundler"
Bundler.require(:default)

require "logger"
require "hashie"
require "celluloid"
require "timers"
require "ducksboard"

require "ducksboard_reporter/version"
require "ducksboard_reporter/reporter"
require "ducksboard_reporter/reporters"
require "ducksboard_reporter/widget"
require "ducksboard_reporter/widgets"

Thread.abort_on_exception = true

module DucksboardReporter
  extend self
  include Celluloid::Logger

  def config
    @config ||= Hashie::Mash.load("config.yml")
  end

  def logger
    @logger || self.logger = Logger.new($stdout)
  end

  def logger=(logger)
    @logger = Celluloid.logger = logger
  end

  def reporters
    @reporters ||= {}
  end

  def widgets
    @widgets ||= []
  end

  def start
    Signal.trap("INT") { exit }

    Ducksboard.api_key = config.api_key

    instanciate_reporters
    instanciate_widgets

    sleep
  end

  def instanciate_reporters
    DucksboardReporter.config.reporters.each do |config|
      reporter = Reporters.const_get(config.klass, false).new(config)
      reporters[config.name] = reporter
      reporter.start
    end
  end

  def instanciate_widgets
    DucksboardReporter.config.widgets.each do |config|
      reporter = reporters[config.reporter]

      unless reporter
        logger.error("Cannot find reporter #{config.reporter}")
        exit
      end

      widget = Widgets.const_get(config.klass, false).new(config.id, reporter, config)
      widget.start
      widgets << widget
    end
  end
end