require 'spec_helper'

describe EsClient do
  it 'has a version number' do
    expect(EsClient::VERSION).not_to be nil
  end

  it 'has http connection' do
    expect(EsClient.client).to be_instance_of(::EsClient::Client)
  end

  it 'http connection persistent by default' do
    expect(EsClient.client.http.data[:persistent]).to eq true
  end

  describe 'index_prefix' do
    after do
      EsClient.index_prefix = nil
    end

    it 'set index name prefix' do
      EsClient.index_prefix = 'prefix'
      expect(EsClient::Index.new('test').name).to eq 'prefix_test'
    end
  end
end
