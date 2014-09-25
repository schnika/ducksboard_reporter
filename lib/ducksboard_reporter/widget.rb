module DucksboardReporter
  class Widget
    include Celluloid
    include Celluloid::Logger

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def start
      every(10) do
        report
      end
    end

    def report
      raise NotImplementedError
    end
  end
end

