module DucksboardReporter
  module Reporters
    class Bandwidth < Reporter

      def collect
        @tx_bytes = 0

        while true do
          begin
            current_tx_bytes = File.read("/sys/class/net/eth0/statistics/tx_bytes").to_i
          rescue Errno::ENOENT
            error("Bandwidth: Cannot open /sys/class/net/eth0/statistics/tx_bytes")
            return
          end

          if @tx_bytes == 0
            @tx_bytes = current_tx_bytes
            next
          end

          @value = (current_tx_bytes - @tx_bytes) * 8
          @tx_bytes = current_tx_bytes
          sleep 1
        end
      end
    end
  end
end

