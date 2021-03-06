$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'es_client'
require 'byebug'
require 'active_model'
require 'ruby-progressbar'

RSpec.configure do |c|
  c.order = :rand
end

EsClient.setup do |config|
  config.log_path = File.expand_path('../../log/elasticsearch.log', __FILE__)
  config.host = "http://localhost:#{ENV['ES_PORT'] || 9200}"
end

class RspecActiveRecordBase
  include ActiveModel::AttributeMethods
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON
  include ActiveModel::Naming

  extend ActiveModel::Callbacks
  define_model_callbacks :save, :destroy

  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def id
    @attributes[:id]
  end

  def to_indexed_json
    @attributes.to_json
  end

  def method_missing(id, *args, &block)
    attributes[id.to_sym] || attributes[id.to_s] || super
  end

  def new_record?
    false
  end

  def persisted?
    !new_record?
  end

  def save
    run_callbacks(:save) {}
  end

  def destroy
    run_callbacks(:destroy) { @destroyed = true }
  end

  def destroyed?
    !!@destroyed
  end

  def self.find_in_batches(options={})
    i = 0
    2.times do
      yield [new(id: i += 1), new(id: i += 1)]
    end
  end

  def self.count
    4
  end
end

class RspecUser < RspecActiveRecordBase
  include ::EsClient::ActiveRecord::Glue
  include ::EsClient::ActiveRecord::Shortcuts

  def self.setup_index
    es_client.index.recreate
    populate
    es_client.index.refresh
  end

  def self.test_data
    [
        {
            id: 1,
            name: 'alex',
            created_at: 3.day.ago
        },
        {
            id: 2,
            name: 'bob',
            created_at: 2.day.ago
        },
        {
            id: 3,
            name: 'john',
            created_at: 1.day.ago
        }
    ]
  end

  def self.populate
    test_data.each do |attrs|
      u = new(attrs)
      u.id = attrs[:id]
      u.save
    end
  end

end
