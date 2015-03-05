module EsClient
  module ActiveRecord
    class Adapter

      attr_accessor :index, :index_name, :document_type
      attr_writer :index, :index_name, :document_type

      def initialize(model)
        @model = model
      end

      def index
        @index ||= ::EsClient::Index.new(index_name)
      end

      def index_name(value=nil)
        if value
          @index_name = value
        else
          @index_name || @model.model_name.plural
        end
      end

      def document_type(value=nil)
        if value
          @document_type = value
        else
          @document_type || @model.model_name.singular
        end
      end

      def save_document(document)
        index.save_document(document_type, document.id, document.as_indexed_json)
      end

      def destroy_document(id)
        index.destroy_document(document_type, id)
      end

      def find(id)
        index.find(document_type, id)
      end
    end
  end
end