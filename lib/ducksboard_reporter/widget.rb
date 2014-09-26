module DucksboardReporter
  class Widget
    include Celluloid
    include Celluloid::Logger

    attr_reader :id, :reporter, :options

    def initialize(klass, id, reporter, options = {})
      @klass = klass
      @id = id
      @reporter = reporter
      @options = options
      @widget = instanciate_widget
    end

    def start
      debug log_format("Started with reporter #{reporter}")

      async.update # initial update
      every(interval) do
        update
      end
    end

    def update
      value = reporter.public_send(value_method)
      debug log_format("Updating value #{value}")
      @widget.update(value)
    end

    def interval
      options.interval || 10
    end

    private

    def log_format(msg)
      @log_prefix ||= "Widget #{self.class.name.split("::").last}(#{id}): "
      @log_prefix + msg
    end

    def value_method
      options.value || :value
    end

    def instanciate_widget
      klass = Class.new(Ducksboard.const_get(@klass, false))
      klass.default_timeout(interval - 1)
      klass.new(id)
    end
  end
end

