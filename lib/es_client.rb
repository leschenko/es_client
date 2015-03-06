require 'es_client/version'
require 'excon'
require 'active_support/all'

module EsClient
  autoload :Client, 'es_client/client'
  autoload :Response, 'es_client/response'
  autoload :Logger, 'es_client/logger'
  autoload :Index, 'es_client/index'

  module ActiveRecord
    autoload :Adapter, 'es_client/active_record/adapter'
    autoload :Glue, 'es_client/active_record/glue'
    autoload :Shortcuts, 'es_client/active_record/shortcuts'
  end

  mattr_accessor :callbacks_enabled, :logger, :logger_options, :host, :http_client_options, :index_prefix

  @@host = 'http://localhost:9200'
  @@http_client_options = {persistent: true}
  @@logger_options = {log_binary: true, log_response: true, pretty: true}
  @@callbacks_enabled = true

  def self.log_path=(path)
    self.logger = ::EsClient::Logger.new(path, logger_options)
  end

  def self.client
    @client ||= ::EsClient::Client.new(host, http_client_options)
  end

  def self.with_log_level(level)
    old_level = logger.level
    begin
      self.logger.level = level.is_a?(Integer) ? level : logger.class.const_get(level.to_s.upcase)
      yield
    ensure
      self.logger.level = old_level
    end
  end

  def self.setup
    yield self
  end
end
