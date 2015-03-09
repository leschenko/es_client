module EsClient
  class Client
    RETRY_TIMES = 1

    HTTP_VERBS = %i(get post put delete head)

    SUCCESS_HTTP_CODES = [200, 201]

    def initialize(host, options)
      @host = host
      @options = options
    end

    HTTP_VERBS.each do |method|
      class_eval <<-DEF, __FILE__, __LINE__ + 1
        def #{method}(path, options={})
          request options.merge(method: :#{method}, path: path)
        end

        def #{method}!(path, options={})
          options[:expects] = SUCCESS_HTTP_CODES
          #{method}(path, options)
        end
      DEF
    end

    def request(options)
      retry_times = 0
      begin
        raw_response = http.request(options)
        response = ::EsClient::Response.new(raw_response.body, raw_response.status, raw_response.headers)
        EsClient.logger.request(http, response, options) if EsClient.logger.try!(:debug?)
        response
      rescue Excon::Errors::SocketError, Excon::Errors::BadRequest => e
        if retry_times >= RETRY_TIMES
          exception = ::EsClient::Client::Error.new(e, self)
          EsClient.logger.exception(exception, http, options) if EsClient.logger
          raise exception
        end
        retry_times += 1
        EsClient.logger.info "[#{retry_times}] Try reconnect to #{@host}"
        reconnect!
        retry
      end
    end

    def http
      @http ||= Excon.new(@host, @options)
    end

    def reconnect!
      @http = nil
    end

    def log(message, level=:info)
      EsClient.logger.try!(level, message)
    end

    class Error < StandardError
      attr_reader :transport, :original_exception

      def initialize(original_exception, transport)
        @transport = transport
        @original_exception = original_exception
        super("#{original_exception.message} (#{original_exception.class})")
        set_backtrace(original_exception.backtrace)
      end
    end
  end
end