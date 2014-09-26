module DucksboardReporter
  class Reporter
    include Celluloid
    include Celluloid::Logger

    attr_reader :options, :value

    def initialize(options = {})
      @options = options
    end

    def start
      debug log_format("Started")
      async.collect
    end

    def collect; end

    def timestamp
      @timestamp || Time.now.to_i
    end

    def to_s
      options.name
    end

    private

    def log_format(msg)
      @log_prefix ||= "Reporter #{self.class.name.split("::").last}(#{to_s}): "
      @log_prefix + msg
    end
  end
end
