require 'spec_helper'
require 'es_client'

describe EsClient::Transport do
  describe 'request' do
    it 'initialize excon' do
      expect(Excon).to receive(:new).with('http://example.com', {persistent: true}).and_return(double(:connection).as_null_object)
      EsClient::Transport.new('http://example.com', {persistent: true}).get('/example')
    end

    context 'success' do
      before do
        Excon.stub({}, lambda { |request_params| {body: request_params[:method].to_s, status: 200} })
      end

      it 'make request' do
        transport = EsClient::Transport.new('http://example.com', {})
        expect(transport.request(method: :options, path: '/example', mock: true).body).to eq 'options'
      end

      it 'make get request' do
        transport = EsClient::Transport.new('http://example.com', {})
        expect(transport.get('/example', mock: true).body).to eq 'get'
      end

      it 'make post request' do
        transport = EsClient::Transport.new('http://example.com', {})
        expect(transport.post('/example', mock: true).body).to eq 'post'
      end
    end

    context 'failure' do
      it 'reconnect on failed request' do
        transport = EsClient::Transport.new('http://example.com', {})
        allow(transport.connection).to receive(:request) { raise Excon::Errors::SocketError.new(StandardError.new) }
        expect(transport).to receive(:reconnect!)
        expect { transport.get('/example', mock: true) }.to raise_error
      end

      it 'retry failed request' do
        transport = EsClient::Transport.new('http://example.com', {})
        allow(transport.connection).to receive(:request) { raise Excon::Errors::SocketError.new(StandardError.new) }
        allow(transport).to receive(:reconnect!)
        expect(transport.connection).to receive(:request).twice
        expect { transport.get('/example', mock: true) }.to raise_error
      end
    end
  end
end