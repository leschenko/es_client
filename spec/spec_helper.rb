$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'es_client'
require 'byebug'

EsClient.setup do |config|
  config.log_path = File.expand_path('../../log/elasticsearch.log', __FILE__)
  config.host = 'http://localhost:9201'
end