require 'es_client/version'
require 'excon'
require 'active_support/all'

module EsClient
  mattr_accessor :logger, :host, :http_client_options

  autoload :Client, 'es_client/client'
  autoload :Response, 'es_client/response'
  autoload :Logger, 'es_client/logger'
  autoload :Index, 'es_client/index'

  @@host = 'http://localhost:9200'
  @@http_client_options = {persistent: true}

  def self.log_path=(value)
    self.logger = ::EsClient::Logger.new(value)
  end

  def self.client
    @client ||= ::EsClient::Client.new(host, http_client_options)
  end

  def self.setup
    yield self
  end
end
