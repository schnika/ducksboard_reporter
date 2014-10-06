module DucksboardReporter
  module Reporters
    class HaproxyLogRequests < Reporter

      attr_reader :requests, :nosrvs

      def collect
        requests = 0
        nosrvs = 0

        begin
          tail = FileTail.new(options[:log_file])
        rescue Errno::ENOENT
          error("HaproxyLogRequests: Log file does not exist #{options[:log_file]}")
          return
        end

        tail.every_second do
          @requests, requests = requests, 0
          @nosrvs, nosrvs = nosrvs, 0
        end

        tail.on_line do |line|
          case line
          when /NOSRV/
            nosrvs += 1
          when /./
            requests += 1
          end
        end

        tail.run
      end
    end
  end
end

