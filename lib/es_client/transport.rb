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
        connection.request(options)
      rescue Excon::Errors::SocketError
        raise if retry_times >= RETRY_TIMES
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
  end
end