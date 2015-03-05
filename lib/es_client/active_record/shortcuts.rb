module EsClient
  module ActiveRecord
    module Shortcuts
      extend ActiveSupport::Concern

      included do
        alias_method :es_doc, :es_client_document
        alias_method :es_save, :es_client_save
        alias_method :es_destroy, :es_client_destroy
      end

      module ClassMethods
        def es_find(*args)
          es_client.find(*args)
        end
      end
    end
  end
end