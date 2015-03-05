require 'spec_helper'

describe EsClient::ActiveRecord::Shortcuts do
  it '#es_doc' do
    record = RspecUser.new.tap(&:save)
    expect(record.es_doc).to eq record.es_client_document
  end

  it '#es_find' do
    RspecUser.new(id: 1).save
    expect(RspecUser.es_find(1)).to eq RspecUser.es_client.find(1)
  end
end