require "rubygems"
require "bundler"
Bundler.require(:default)

require "logger"
require "hashie"
require "celluloid"
require "timers"

require "ducksboard_reporter/version"
require "ducksboard_reporter/reporter"
require "ducksboard_reporter/reporters"
require "ducksboard_reporter/widget"
require "ducksboard_reporter/widgets"

Thread.abort_on_exception = true

module DucksboardReporter
  extend self

  def config
    @config ||= Hashie::Mash.load("config.yml")
  end

  def logger
    @logger ||= Celluloid.logger = Logger.new($stdout)
  end

  def start
    Connector.new.start
    sleep
  end

  class Connector
    def start
      instanciate_reporters
      instanciate_widgets
    end

    private

    def instanciate_reporters
      @reporter_instances = {}
      DucksboardReporter.config.reporters.each do |config|
        reporter = Reporters.const_get(config.klass).new(config)
        @reporter_instances[config.name] = reporter
        reporter.async.collect
      end
    end

    def instanciate_widgets
      @widget_instances = DucksboardReporter.config.widgets.map do |config|
        widget = Widgets.const_get(config.klass).new(config)
        widget.async.report
        widget
      end
    end
  end
end
