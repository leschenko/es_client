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

  it 'destroy document' do
    expect(RspecUser.es_client.index).to receive(:destroy_document).with('rspec_user', 1)
    RspecUser.es_client.destroy_document(1)
  end

  describe 'find' do
    it 'find document' do
      expect(RspecUser.es_client.index).to receive(:find).with('rspec_user', 1)
      RspecUser.es_client.find(1)
    end
  end
end
