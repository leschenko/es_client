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

  describe 'update' do
    it 'update es document' do
      expect(RspecUser.es_client).to receive(:update_document)
      RspecUser.new(id: 1, name: 'bob').es_client_update
    end

    it 'do not update new record' do
      expect(RspecUser.es_client).not_to receive(:update_document)
      record = RspecUser.new(id: 1, name: 'bob')
      allow(record).to receive(:new_record?).and_return(true)
      record.es_client_update
    end
  end

  describe 'update fields' do
    it 'update fields in es document' do
      expect(RspecUser.es_client).to receive(:update_fields).with(instance_of(RspecUser), {name: 'Bob'})
      RspecUser.new(id: 1).es_client_update_fields(name: 'Bob')
    end

    it 'do not update fields for new record' do
      expect(RspecUser.es_client).not_to receive(:update_fields)
      record = RspecUser.new(id: 1, name: 'bob')
      allow(record).to receive(:new_record?).and_return(true)
      record.es_client_update_fields(name: 'Bob')
    end
  end

  describe 'record es document' do
    it 'return es document' do
      expect(RspecUser.es_client).to receive(:find).with(1)
      RspecUser.new(id: 1, name: 'bob').es_client_document
    end

    it 'fetch es document once' do
      expect(RspecUser.es_client).to receive(:find).with(1).once
      record = RspecUser.new(id: 1, name: 'bob')
      record.es_client_document
      record.es_client_document
    end

    it 'force fetch es document' do
      expect(RspecUser.es_client).to receive(:find).with(1).twice
      record = RspecUser.new(id: 1, name: 'bob')
      record.es_client_document
      record.es_client_document(true)
    end
  end

  describe 'reindex' do
    it 'reindex current scope' do
      expect(RspecUser.es_client).to receive(:import).twice.with(instance_of(Array))
      RspecUser.es_client_reindex
    end

    it 'reindex current scope with progress' do
      expect(RspecUser.es_client).to receive(:import).twice.with(instance_of(Array))
      RspecUser.es_client_reindex_with_progress(batch_size: 1)
    end
  end
end
