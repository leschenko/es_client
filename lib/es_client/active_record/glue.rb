module EsClient
  module ActiveRecord
    module Glue
      extend ActiveSupport::Concern

      included do
        class_attribute :es_client
        self.es_client = ::EsClient::ActiveRecord::Adapter.new(self)
        after_save :es_client_save, if: :es_client_callbacks_enabled?
        after_destroy :es_client_destroy, if: :es_client_callbacks_enabled?
      end

      def es_client_save
        es_client.save_document(self)
      end

      def es_client_destroy
        return if new_record?
        es_client.destroy_document(id)
      end

      def es_client_document(force=false)
        return @es_client_document if !force && defined?(@es_client_document)
        @es_client_document = es_client.find(id)
      end

      def es_client_callbacks_enabled?
        EsClient.callbacks_enabled
      end

      def as_indexed_json
        as_json
      end
    end
  end
end