require "rb-inotify"

module DucksboardReporter
  module Reporters
    class HaproxyLogRequests < Reporter

      class LogRotateWatcher
        include Celluloid
        include Celluloid::Logger

        def initialize(reporter, file)
          @reporter = reporter
          @file = file
          @dir = File.dirname(file)
        end

        def start
          notifier = INotify::Notifier.new
          info("LogRotateWatcher: Watcher started for #{@file}")
          notifier.watch(@dir, :create) do |event|
	    if event.absolute_name == @file
              info("LogRotateWatcher: New file created #{@file}")
              @reporter.async.open_log
	    end
          end
        end
      end

      attr_reader :requests, :nosrvs

      def collect
        requests = 0
        nosrvs = 0
        watcher = LogRotateWatcher.new(self, options.logfile).start

        open_log

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
          error("HaproxyLogRequests: Waiting for file #{options.logfile} to be created")
          sleep 5
          retry
        end
        @file.seek(0, IO::SEEK_END)
      end
    end
  end
end


