module EsClient
  class Logger < ::Logger

    def request(options, connection, response)
      return unless debug?
      took = response.try!(:decoded).try!(:fetch, 'took') ? response.decoded['took'] : 'N/A'
      debug "[#{took} msec] #{to_curl(options, connection)}"
    end

    def exception(e, options=nil, connection=nil)
      backtrace = e.backtrace.map { |l| "#{' ' * 2}#{l}" }.join("\n")
      curl = "\n  #{to_curl(options, connection)}" if options && connection
      error "#{e.class} #{e.message} #{curl}\n#{backtrace}\n\n"
    end

    private

    def to_curl(options, connection)
      res = 'curl -X '
      res << options[:method].to_s.upcase

      res << " '#{connection.params[:scheme]}://#{connection.params[:host]}#{options[:path]}"
      if options[:query].present?
        res << '?'
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