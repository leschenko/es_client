module EsClient
  class Logger < ::Logger
    def initialize(path, options)
      super(path)
      @options = options
    end

    def request(http, response, options)
      log_level = response.success? ? :debug : :warn
      return unless send("#{log_level}?")
      took = response.try!(:decoded).try!(:[], 'took') ? response.decoded['took'] : 'N/A'
      message = "[#{response.code}](#{took} msec) #{to_curl(http, options)}"
      message << "\n#{JSON.pretty_generate(response.decoded)}" if @options[:log_response] && response.try!(:decoded)
      send log_level, message
    end

    def exception(e, http=nil, options=nil)
      return unless error?
      backtrace = e.backtrace.map { |l| "#{' ' * 2}#{l}" }.join("\n")
      curl = "\n  #{to_curl(http, options)}" if options && http
      error "#{e.class} #{e.message} #{curl}\n#{backtrace}\n\n"
    end

    private

    def to_curl(http, options)
      res = 'curl -i -X '
      res << options[:method].to_s.upcase

      res << " '#{http.data[:scheme]}://#{http.data[:host]}"
      res << ":#{http.data[:port]}" if http.data[:port]
      res << options[:path]
      if options[:query].present?
        res << '?'
        res << options[:query].is_a?(String) ? options[:query] : options[:query].to_query
      elsif @options[:pretty]
        res << '?'
      end
      res << '&pretty' if @options[:pretty]
      res << "'"

      if options[:body]
        if options[:path].include?('/_bulk')
          binary_data = @options[:log_binary] ? options[:body] : '... data omitted ...'
          res << " --data-binary '#{binary_data}'"
        else
          res << " -d '#{pretty_json(options[:body])}'"
        end
      end
      res
    end

    def pretty_json(string)
      return if string.blank?
      return string unless @options[:pretty]
      JSON.pretty_generate(JSON.parse(string)).gsub("'", '\u0027')
    end
  end
end