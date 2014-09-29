require "rubygems"

require "logger"
require "hashie"
require "celluloid"
require "timers"
require "ducksboard"

require "ducksboard_reporter/version"
require "ducksboard_reporter/reporter"
require "ducksboard_reporter/reporters"
require "ducksboard_reporter/widget"

Thread.abort_on_exception = true

module DucksboardReporter
  extend self

  include Celluloid::Logger

  def logger
    @logger ||= Celluloid.logger = Logger.new($stdout)
  end

  class App

    attr_reader :config, :reporters, :widgets

    def initialize(config_file)
      @config ||= Hashie::Mash.load(config_file)

      register_reporters
      register_widgets
    end

    def start
      Signal.trap("INT") { exit }

      Ducksboard.api_key = config.api_key

      sleep # let the actors continue their work
    end

    def register_reporters
      @reporters = {}

      @config.reporters.each do |config|
        reporter = Reporters.const_get(config.type, false).new(config.name)

        if config.options
          config.options.each do |method, value|
            reporter.send("#{method}=", value)
          end
        end

        @reporters[reporter.name] = reporter
      end
    end

    def register_widgets
      @widgets = []

      @config.widgets.each do |config|
        reporter = @reporters[config.reporter]

        unless reporter
          logger.error("Cannot find reporter #{config.reporter}")
          exit
        end

        widget = Widget.new(config.type, config.id, reporter, config)
        @widgets << widget
      end
    end

    def start_reporters
      @reporters.each {|_, reporter| reporter.start }
    end

    def start_widgets
      @widgets.each(&:start)
    end

    private

    def logger
      DucksboardReporter.logger
    end
  end
end
