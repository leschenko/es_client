module EsClient
  class Logger < ::Logger

    def request(options, http, response)
      return unless debug?
      took = response.try!(:decoded).try!(:[], 'took') ? response.decoded['took'] : 'N/A'
      debug "[#{response.code}](#{took} msec) #{to_curl(options, http)}"
    end

    def exception(e, options=nil, http=nil)
      backtrace = e.backtrace.map { |l| "#{' ' * 2}#{l}" }.join("\n")
      curl = "\n  #{to_curl(options, http)}" if options && http
      error "#{e.class} #{e.message} #{curl}\n#{backtrace}\n\n"
    end

    private

    def to_curl(options, http)
      res = 'curl -i -X '
      res << options[:method].to_s.upcase

      res << " '#{http.params[:scheme]}://#{http.params[:host]}"
      res << ":#{http.params[:port]}" if http.params[:port]
      res << options[:path]
      res << '?'
      res << 'pretty'
      if options[:query].present?
        res << '&'
        res << options[:query].is_a?(String) ? options[:query] : options[:query].to_query
      end
      res << "'"

      res << " -d '#{pretty_json(options[:body])}'" if options[:body]
      res
    end

    def pretty_json(string)
      return if string.blank?
      JSON.pretty_generate(JSON.parse(string)).gsub("'", '\u0027')
    end

  end
end