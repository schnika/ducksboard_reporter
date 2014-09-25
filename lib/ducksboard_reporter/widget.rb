module DucksboardReporter
  class Widget
    include Celluloid
    include Celluloid::Logger

    attr_reader :id, :reporter, :options

    def initialize(id, reporter, options = {})
      @id = id
      @reporter = reporter
      @options = options
    end

    def start
      debug log_format("Started with reporter #{reporter}")

      async.update # initial update
      every(options.interval || 10) do
        update
      end
    end

    def update
      raise NotImplementedError
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
  end
end

