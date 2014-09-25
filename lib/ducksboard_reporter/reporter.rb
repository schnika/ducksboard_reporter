module DucksboardReporter
  class Reporter
    include Celluloid
    include Celluloid::Logger

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def value
      raise NotImplementedError
    end

    def collect; end

    def timestamp
      Time.now.to_i
    end
  end
end
