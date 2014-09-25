module DucksboardReporter
  module Widgets
    class Box < Widget

      def update
        value = reporter.public_send(value_method)
        debug log_format("Updating value #{value}")
        widget.update(value)
      end

      def widget
        @widget ||= begin
                      klass = Class.new(Ducksboard::Box)
                      klass.default_timeout(interval - 1)
                      klass.new(id)
                    end
      end
    end
  end
end

