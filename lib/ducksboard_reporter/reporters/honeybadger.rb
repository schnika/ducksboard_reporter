require "open-uri"

module DucksboardReporter
  module Reporters
    class Honeybadger < Reporter

      def collect
        every(10) do
          @data = JsonRemote.get(url, timeout: 5)
          if @data.nil? && (e = JsonRemote.request.exception)
            error(log_format("Cannot request data from Honeybadger #{e}"))
          end
        end
      end

      def unresolved_fault_count
        @data.unresolved_fault_count if @data
      end

      private

      def url
        @url ||= "https://api.honeybadger.io/v1/projects/#{options[:project_id]}?auth_token=#{options[:api_key]}"
      end
    end
  end
end


