require 'spec_helper'

describe EsClient::Index do
  describe 'exists' do
    it 'index not exists' do
      index = EsClient::Index.new('test_index')
      index.delete
      expect(index.exists?).to eq false
    end

    it 'index not exists' do
      index = EsClient::Index.new('test_index')
      index.create
      expect(index.exists?).to eq true
    end
  end

  describe 'create' do
    it 'create index' do
      index = EsClient::Index.new('test_index')
      index.delete
      expect(index.create.success?).to eq true
    end

    it 'create index with mapping and settings' do
      index = EsClient::Index.new('test_index', mappings: {product: {properties: {sku: {type: 'string'}}}}, settings: {number_of_shards: 1})
      index.delete
      expect(index.create.success?).to eq true
      expect(index.get_mapping).to eq({'product' => {'properties' => {'sku' => {'type' => 'string'}}}})
      expect(index.get_settings['index']['number_of_shards']).to eq '1'
    end

    it 'create index error' do
      index = EsClient::Index.new('test_index')
      index.create
      expect(index.create.success?).to eq false
    end
  end

  describe 'delete' do
    it 'delete index' do
      index = EsClient::Index.new('test_index')
      index.create
      expect(index.delete.success?).to eq true
    end

    it 'delete index error' do
      index = EsClient::Index.new('test_index')
      index.delete
      expect(index.delete.success?).to eq false
    end
  end

  describe 'put_mapping' do
    it 'update mapping' do
      index = EsClient::Index.new('test_index')
      index.create
      expect(index.put_mapping('product', {properties: {sku: {type: 'string'}}}).success?).to eq true
      expect(index.get_mapping).to eq({'product' => {'properties' => {'sku' => {'type' => 'string'}}}})
    end
  end
end