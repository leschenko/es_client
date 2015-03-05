require 'spec_helper'

describe EsClient::ActiveRecord::Glue do
  describe 'callbacks' do
    it 'save document after save' do
      expect(RspecUser.es_client).to receive(:save_document).with(instance_of(RspecUser))
      RspecUser.new(id: 1, name: 'bob').save
    end

    it 'destroy document after destroy' do
      expect(RspecUser.es_client).to receive(:destroy_document).with(1)
      RspecUser.new(id: 1, name: 'bob').destroy
    end

    it 'allow to disable callbacks' do
      allow(EsClient).to receive(:callbacks_enabled).and_return(false)
      expect(RspecUser.es_client).not_to receive(:save_document)
      RspecUser.new(id: 1, name: 'bob').save
    end
  end
end
