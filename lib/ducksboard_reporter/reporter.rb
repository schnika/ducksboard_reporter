module DucksboardReporter
  class Reporter
    include Celluloid
    include Celluloid::Logger

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def start
      async.collect
    end

    def value
      raise NotImplementedError
    end

    def collect; end

    def timestamp
      Time.now.to_i
    end

    def to_s
      options.name
    end
  end
end
