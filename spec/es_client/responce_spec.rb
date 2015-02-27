require 'spec_helper'

describe EsClient::Response do
  describe '#success?' do
    it 'return true on success code' do
      expect(EsClient::Response.new('', 200).success?).to be_truthy
    end

    it 'return false on failure code' do
      expect(EsClient::Response.new('', 500).success?).to be_falsey
    end
  end

  describe '#failure?' do
    it 'return true on failure code' do
      expect(EsClient::Response.new('', 500).failure?).to be_truthy
    end
  end

  describe '#decoded' do
    it 'return decoded json' do
      expect(EsClient::Response.new('{"key": "value"}', 200).decoded).to eq('key' => 'value')
    end
  end
end
