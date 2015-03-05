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

  describe 'mapping' do
    it 'update mapping' do
      index = EsClient::Index.new('test_index')
      index.recreate
      expect(index.put_mapping('product', {properties: {sku: {type: 'string'}}}).success?).to eq true
      expect(index.get_mapping).to eq({'product' => {'properties' => {'sku' => {'type' => 'string'}}}})
    end
  end

  describe 'settings' do
    it 'update settings' do
      index = EsClient::Index.new('test_index')
      index.recreate
      expect(index.put_settings({refresh_interval: '2s'}).success?).to eq true
      expect(index.get_settings['index']['refresh_interval']).to eq '2s'
    end
  end

  describe 'save document' do
    it 'save document' do
      index = EsClient::Index.new('test_index')
      index.recreate
      expect(index.save_document('test', nil, {}).success?).to eq true
    end
  end

  describe 'update document' do
    it 'update document' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.save_document('test', 1, {id: 1, name: 'test', description: 'text'})
      index.update_document('test', 1, {name: 'test1'})
      expect(index.find('test', 1)['name']).to eq 'test1'
      expect(index.find('test', 1)['description']).to eq 'text'
    end
  end

  describe 'destroy document' do
    it 'destroy document' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.save_document('test', 1, {id: 1, name: 'test'})
      expect(index.destroy_document('test', 1).success?).to eq true
    end
  end

  describe 'find' do
    it 'find document' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.save_document('test', 1, {id: 1, name: 'test'})
      expect(index.find('test', 1)['name']).to eq 'test'
    end
  end

  describe 'bulk' do
    it 'perform bulk indexing' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.bulk(:index, 'test', [{id: 1, name: 'test'}])
      expect(index.find('test', 1)['name']).to eq 'test'
    end

    it 'perform bulk update' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.save_document('test', 1, {id: 1, name: 'test'})
      index.bulk(:update, 'test', [{id: 1, name: 'updated name'}])
      expect(index.find('test', 1)['name']).to eq 'updated name'
    end

    it 'perform bulk update with options' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.bulk(:update, 'test', [{id: 1, name: 'updated name', bulk_options: {doc_as_upsert: true}}])
      expect(index.find('test', 1)['name']).to eq 'updated name'
    end

    it 'perform bulk delete' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.save_document('test', 1, {id: 1, name: 'test'})
      index.bulk(:delete, 'test', [{id: 1}])
      expect(index.find('test', 1)).to be_nil
    end
  end

  it 'refresh index' do
    index = EsClient::Index.new('test_index')
    index.recreate
    expect(index.refresh.success?).to eq true
  end

  describe 'search' do
    it 'perform query' do
      index = EsClient::Index.new('test_index')
      index.recreate
      index.save_document('test', 1, {id: 1, name: 'test'})
      index.refresh
      expect(index.search({query: {ids: {values: [1]}}}, type: 'test').decoded['hits']['hits'].length).to eq 1
    end
  end
end