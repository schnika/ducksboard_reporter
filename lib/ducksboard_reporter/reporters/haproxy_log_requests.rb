module DucksboardReporter
  module Reporters
    class HaproxyLogRequests < Reporter

      def collect
        requests = 0
        nosrvs = 0

        begin
          file = File.open(options.logfile, "r")
        rescue Errno::ENOENT
          error("HaproxyLogRequests: Cannot open #{options.logfile}")
          return
        end

        file.seek(0, IO::SEEK_END)
        @time = Time.now.to_i

        while true do
          if (current_time = Time.now.to_i) > @time # flush every second
            @requests, requests = requests, 0
            @nosrvs, nosrvs = nosrvs, 0
            @time = current_time
          end

          IO.select([file])
          line = file.gets

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
    end
  end
end


