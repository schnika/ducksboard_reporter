require "faraday"
require "hashie"

module DucksboardReporter
  class JsonRemote
    attr_reader :response, :exception

    class << self
      def get(url, options = {})
        request = Thread.current[:_json_remote_request] = new(url, options)
        request.get
      end

      def request
        Thread.current[:_json_remote_request]
      end
    end

    def initialize(url, options = {})
      @url = url
      @connection_timeout = options[:connection_timeout] || options[:timeout]
      @read_timeout = options[:read_timeout] || options[:timeout]
    end

    def get
      @exception = nil
      conn = Faraday.new(
        url: host_with_scheme_and_port,
        headers: {accept: "application/json"}
      )
      @response = conn.get(uri.request_uri, request_options)
      Hashie::Mash.new(JSON.parse(@response.body))
    rescue => e
      @exception = e
      nil
    end

    private

    def host_with_scheme_and_port
      host = "#{uri.scheme}://#{uri.host}"
      host << ":#{uri.port}" if uri.port != 80
      host
    end

    def uri
      @uri ||= URI.parse(@url)
    end

    def request_options
      options = {}
      options[:connection_timeout] = @connection_timeout if @connection_timeout
      options[:read_timeout]       = @read_timeout if @read_timeout
      options
    end
  end
end

