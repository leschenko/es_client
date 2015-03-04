require 'spec_helper'

describe EsClient::Index do
  describe 'exists' do
    it 'index not exists' do
      index = EsClient::Index.new('test_index')
      allow(EsClient.client).to receive(:head).with('/test_index').and_return(double(:response, success?: false))
      expect(index.exists?).to eq false
    end

    it 'index exists' do
      index = EsClient::Index.new('test_index')
      allow(EsClient.client).to receive(:head).with('/test_index').and_return(double(:response, success?: true))
      expect(index.exists?).to eq true
    end
  end

  describe 'create' do
    it 'create index' do
      index = EsClient::Index.new('test_index')
      allow(EsClient.client).to receive(:post).with('/test_index', {}).and_return(double(:response, success?: true))
      expect(index.create.success?).to eq true
    end
  end

  describe 'delete' do
    it 'create index' do
      index = EsClient::Index.new('test_index')
      allow(EsClient.client).to receive(:delete).with('/test_index').and_return(double(:response, success?: true))
      expect(index.delete.success?).to eq true
    end
  end

  it 'recreate index' do
    index = EsClient::Index.new('test_index')
    expect(index).to receive(:delete)
    expect(index).to receive(:create)
    index.recreate
  end
end