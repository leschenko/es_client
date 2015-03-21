require 'spec_helper'

describe EsClient::ActiveRecord::Adapter do
  describe 'index name' do
    it 'determine index name from model' do
      expect(RspecUser.es_client.index_name).to eq 'rspec_users'
    end

    it 'allow to define custom index name' do
      RspecUser.es_client.index_name('custom_index_name')
      expect(RspecUser.es_client.index_name).to eq 'custom_index_name'
      RspecUser.es_client.instance_variable_set(:@index_name, nil)
    end
  end

  describe 'document type' do
    it 'determine document type from model' do
      expect(RspecUser.es_client.document_type).to eq 'rspec_user'
    end

    it 'allow to define custom document type' do
      RspecUser.es_client.document_type('custom_document_type')
      expect(RspecUser.es_client.document_type).to eq 'custom_document_type'
      RspecUser.es_client.instance_variable_set(:@document_type, nil)
    end
  end

  it 'save document' do
    expect(RspecUser.es_client.index).to receive(:save_document).with('rspec_user', 1, {id: 1, name: 'bob'})
    RspecUser.es_client.save_document(RspecUser.new(id: 1, name: 'bob'))
  end

  describe 'update document' do
    it 'update document' do
      expect(RspecUser.es_client.index).to receive(:update_document).with('rspec_user', 1, {name: 'arnold'})
      record = RspecUser.new(id: 1, name: 'bob')
      allow(record).to receive(:changes).and_return({name: %w(bob arnold)})
      RspecUser.es_client.update_document(record)
    end
  end

  describe 'update document fields' do
    it 'update document fields' do
      expect(RspecUser.es_client.index).to receive(:update_document).with('rspec_user', 1, {name: 'arnold'})
      record = RspecUser.new(id: 1, name: 'bob')
      RspecUser.es_client.update_fields(record, {name: 'arnold'})
    end
  end

  it 'destroy document' do
    expect(RspecUser.es_client.index).to receive(:destroy_document).with('rspec_user', 1)
    RspecUser.es_client.destroy_document(1)
  end

  describe 'find' do
    it 'find document' do
      expect(RspecUser.es_client.index).to receive(:find).with('rspec_user', 1)
      RspecUser.es_client.find(1)
    end

    it 'find multiple documents' do
      expect(RspecUser.es_client.index).to receive(:search).with({query: {ids: {values: [1], type: 'rspec_user'}}, size: 1}, type: 'rspec_user')
      RspecUser.es_client.find([1])
    end
  end

  describe 'import' do
    it 'import batch of records' do
      expect(RspecUser.es_client.index).to receive(:bulk).with(:index, 'rspec_user', [{id: 1}])
      RspecUser.es_client.import([RspecUser.new(id: 1)])
    end
  end

  describe 'mapping' do
    it 'fetch mapping' do
      expect(RspecUser.es_client.index).to receive(:get_mapping)
      RspecUser.es_client.mapping
    end

    it 'set mapping' do
      RspecUser.es_client.index.options[:mappings] = {}
      RspecUser.es_client.mapping(test: {properties: {notes: {type: 'string'}}})
      expect(RspecUser.es_client.index.options[:mappings]).to include(test: {properties: {notes: {type: 'string'}}})
    end

    it 'set append mapping' do
      RspecUser.es_client.index.options[:mappings] = {}
      RspecUser.es_client.mapping(test: {properties: {prop1: {type: 'string'}}})
      RspecUser.es_client.mapping(test: {properties: {prop2: {type: 'string'}}})
      expect(RspecUser.es_client.index.options[:mappings][:test][:properties]).to include(prop1: {type: 'string'})
      expect(RspecUser.es_client.index.options[:mappings][:test][:properties]).to include(prop2: {type: 'string'})
    end
  end

  describe 'settings' do
    it 'fetch settings' do
      expect(RspecUser.es_client.index).to receive(:get_settings)
      RspecUser.es_client.settings
    end

    it 'set settings' do
      RspecUser.es_client.index.options[:settings] = {}
      RspecUser.es_client.settings(refresh_interval: '3s')
      expect(RspecUser.es_client.index.options[:settings]).to include(refresh_interval: '3s')
    end
  end

  describe 'search' do
    it 'perform search query' do
      expect(RspecUser.es_client.index).to receive(:search).with({query: {query_string: {query: 'test'}}}, type: 'rspec_user')
      RspecUser.es_client.search(query: {query_string: {query: 'test'}})
    end
  end
end
