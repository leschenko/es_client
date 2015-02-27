module EsClient
  class Transport

    RETRY_TIMES = 1

    def initialize(host, options)
      @host = host
      @options = options
    end

    def get(path, options={})
      request options.merge(method: :get, path: path)
    end

    def post(path, options={})
      request options.merge(method: :post, path: path)
    end

    def put(path, options={})
      request options.merge(method: :put, path: path)
    end

    def delete(path, options={})
      request options.merge(method: :delete, path: path)
    end

    def head(path, options={})
      request options.merge(method: :head, path: path)
    end

    def request(options)
      retry_times = 0
      begin
        raw_response = connection.request(options)
        response = ::EsClient::Response.new(raw_response.body, raw_response.status, raw_response.headers)
        EsClient.logger.request(options, connection, response) if EsClient.logger.try!(:debug?)
        response
      rescue Excon::Errors::SocketError => e
        if retry_times >= RETRY_TIMES
          exception = ::EsClient::Transport::Error.new(e, self)
          EsClient.logger.exception(exception, options, connection) if EsClient.logger
          raise exception
        end
        retry_times += 1
        reconnect!
        retry
      end
    end

    def connection
      @connection ||= Excon.new(@host, @options)
    end

    def reconnect!
      @connection = nil
    end

    def log(message, level=:info)
      EsClient.logger.try!(level, message)
    end

    class Error < StandardError

      attr_reader :transport

      def initialize(excon_error, transport)
        @transport = transport
        super("#{excon_error.message} (#{excon_error.class})")
        set_backtrace(excon_error.backtrace)
      end

    end
  end
end