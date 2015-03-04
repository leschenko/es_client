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
end
