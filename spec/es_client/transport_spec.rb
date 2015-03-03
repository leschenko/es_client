require 'spec_helper'

describe EsClient::Transport do
  describe 'request' do
    it 'initialize excon' do
      expect(Excon).to receive(:new).with('http://example.com', {persistent: true}).and_return(double(:http).as_null_object)
      EsClient::Transport.new('http://example.com', {persistent: true}).get('/example')
    end

    context 'success' do
      before do
        Excon.stub({}, {})
      end

      it 'make request' do
        transport = EsClient::Transport.new('http://example.com', {})
        expect(transport.http).to receive(:request).with(hash_including(method: :options)).and_return(double(:response).as_null_object)
        transport.request(method: :options, path: '/example', mock: true)
      end

      it 'make get request' do
        transport = EsClient::Transport.new('http://example.com', {})
        expect(transport.http).to receive(:request).with(hash_including(method: :get)).and_return(double(:response).as_null_object)
        transport.get('/example', mock: true)
      end

      it 'make post request' do
        transport = EsClient::Transport.new('http://example.com', {})
        expect(transport.http).to receive(:request).with(hash_including(method: :post)).and_return(double(:response).as_null_object)
        transport.post('/example', mock: true)
      end
    end

    context 'failure' do
      it 'reconnect on failed request' do
        transport = EsClient::Transport.new('http://example.com', {})
        allow(transport.http).to receive(:request) { raise Excon::Errors::SocketError.new(StandardError.new) }
        expect(transport).to receive(:reconnect!)
        expect { transport.get('/example', mock: true) }.to raise_error
      end

      it 'retry failed request' do
        transport = EsClient::Transport.new('http://example.com', {})
        allow(transport.http).to receive(:request) { raise Excon::Errors::SocketError.new(StandardError.new) }
        allow(transport).to receive(:reconnect!)
        expect(transport.http).to receive(:request).twice
        expect { transport.get('/example', mock: true) }.to raise_error
      end
    end
  end
end