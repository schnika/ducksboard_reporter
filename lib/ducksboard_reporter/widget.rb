module DucksboardReporter
  class Widget
    include Celluloid
    include Celluloid::Logger

    attr_reader :id, :reporter, :options, :updater

    def initialize(klass, id, reporter, options = {})
      @klass = klass
      @id = id
      @reporter = reporter
      @options = options
      @updater = instanciate_updater
    end

    def start
      debug log_format("Started using reporter #{reporter}")

      every(interval) do
        update
      end
    end

    def update
      value = case value_method
      when Symbol
        @reporter.public_send(value_method)
      when Hash
        value_method.inject({}) do |memo, (k, v)|
          memo[k] = (v.is_a?(Symbol) ? @reporter.public_send(v) : v)
          memo
        end
      else
        value_method
      end

      debug log_format("Updating value #{value}")

      @updater.update(value)
    rescue Net::ReadTimeout, Net::OpenTimeout
      # accept timeout errors
    end

    def interval
      options[:interval] || 10
    end

    private

    def log_format(msg)
      @log_prefix ||= "Widget #{self.class.name.split("::").last}(#{id}): "
      @log_prefix + msg
    end

    def value_method
      options[:value] || :value
    end

    def instanciate_updater
      klass = Class.new(Ducksboard::Widget)
      klass.default_timeout(interval - 1)
      klass.new(@id)
    end
  end
end

