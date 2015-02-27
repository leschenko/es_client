require 'es_client/version'
require 'excon'
require 'active_support/all'

module EsClient
  autoload :Transport, 'es_client/transport'
  autoload :Response, 'es_client/response'
end
