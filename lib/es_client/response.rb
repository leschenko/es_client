module EsClient

  class Response
    attr_reader :body, :code, :headers

    def initialize(body, code, headers={})
      @body = body
      @code = code.to_i
      @headers = headers
    end

    def success?
      code > 0 && code < 400
    end

    def failure?
      !success?
    end

    def decoded
      @decoded ||= JSON.load(@body)
    end
  end

end