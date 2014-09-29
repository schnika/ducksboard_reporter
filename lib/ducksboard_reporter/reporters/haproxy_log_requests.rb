require "rb-inotify"

module DucksboardReporter
  module Reporters
    class HaproxyLogRequests < Reporter

      class LogRotateWatcher
        include Celluloid

        def initialize(reporter, file)
          super
          @reporter = reporter
          @file = file
          @dir = File.dirname(file)
        end

        def start
          notifier = INotify::Notifier.new
          notifier.watch(@dir, :create) do |event|
            @reporter.async.open_log if event.absolute_name == @file
          end
        end
      end

      attr_reader :requests, :nosrvs

      def collect
        requests = 0
        nosrvs = 0


        @timestamp = Time.now.to_i

        while true do
          if (current_time = Time.now.to_i) > @timestamp # flush every second
            @requests, requests = requests, 0
            @nosrvs, nosrvs = nosrvs, 0
            @timestamp = current_time
          end

          IO.select([@file])
          line = @file.gets

          case line
          when /NOSRV/
            nosrvs += 1
          when /./
            requests += 1
          else
            sleep 0.1
          end
        end
      end

      def open_log
        begin
          old_file = @file
          @file = File.open(options.logfile, "r")
          old_file.close if old_file rescue nil
        rescue Errno::ENOENT
          error("HaproxyLogRequests: Cannot open #{options.logfile}")
          return
        end
        @file.seek(0, IO::SEEK_END)
      end
    end
  end
end


