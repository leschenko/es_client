require 'es_client/version'
require 'excon'
require 'active_support/all'

module EsClient
  mattr_accessor :logger

  autoload :Transport, 'es_client/transport'
  autoload :Response, 'es_client/response'
  autoload :Logger, 'es_client/logger'

  def self.log_path=(value)
    self.logger = ::EsClient::Logger.new(value)
  end

  def self.setup
    yield self
  end
end
