require 'spec_helper'

describe EsClient::ActiveRecord::Adapter do
  describe 'index name' do
    it 'determine index name from model' do
      expect(RspecUser.es_client.index_name).to eq 'rspec_users'
    end

    it 'allow to define custom index name' do
      RspecUser.es_client.index_name('custom_index_name')
      expect(RspecUser.es_client.index_name).to eq 'custom_index_name'
    end
  end

  describe 'document type' do
    it 'determine document type from model' do
      expect(RspecUser.es_client.document_type).to eq 'rspec_user'
    end

    it 'allow to define custom document type' do
      RspecUser.es_client.document_type('custom_document_type')
      expect(RspecUser.es_client.document_type).to eq 'custom_document_type'
    end
  end
end
