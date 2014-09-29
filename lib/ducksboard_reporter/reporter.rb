module DucksboardReporter
  class Reporter
    include Celluloid
    include Celluloid::Logger

    attr_accessor :value, :timestamp, :name

    def initialize(name)
      @name = name
    end

    def start
      debug(log_format("Started"))
      async.collect
    end

    def collect; end

    def timestamp
      @timestamp || Time.now.to_i
    end

    private

    def log_format(msg)
      @log_prefix ||= "Reporter #{self.class.name.split("::").last}(#{@name}): "
      @log_prefix + msg
    end
  end
end
