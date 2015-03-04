require 'spec_helper'

describe EsClient::Logger do
  it 'log request' do
    Excon.stub({}, {body: '{"took": 10}'})
    transport = EsClient::Client.new('http://example.com', {})
    expect(EsClient.logger).to receive(:debug).with(Regexp.new(Regexp.escape('[200](10 msec) curl')))
    transport.get('/example', mock: true)
  end

  it 'log exception' do
    transport = EsClient::Client.new('http://example.com', {})
    allow(transport.http).to receive(:request) { raise Excon::Errors::SocketError.new(StandardError.new) }
    allow(transport).to receive(:reconnect!)
    expect(EsClient.logger).to receive(:error).with(/SocketError.*?curl/m)
    expect { transport.get('/example',) }.to raise_error
  end
end