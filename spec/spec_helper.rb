$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'es_client'

EsClient.setup do |config|
  config.log_path = File.expand_path('../../log/elasticsearch.log', __FILE__)
end