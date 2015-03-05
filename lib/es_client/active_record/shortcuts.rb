module EsClient
  module ActiveRecord
    module Shortcuts
      extend ActiveSupport::Concern

      included do
        alias_method :es_doc, :es_client_document
      end

      module ClassMethods
        def es_find(*args)
          es_client.find(*args)
        end
      end
    end
  end
end