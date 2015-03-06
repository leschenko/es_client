module EsClient
  module ActiveRecord
    class Adapter
      attr_reader :index, :index_name, :document_type, :mapping, :settings

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

      def mapping(value=nil)
        if value
          @index.options[:mappings] ||= {}
          @index.options[:mappings].deep_merge!(value)
        else
          index.get_mapping
        end
      end

      def settings(value=nil)
        if value
          @index.options[:settings] ||= {}
          @index.options[:settings].deep_merge!(value)
        else
          index.get_settings
        end
      end

      def save_document(record)
        index.save_document(document_type, record.id, record.as_indexed_json)
      end

      def update_document(record, additional_doc=nil)
        doc = record.changes.map { |k, v| [k, v.last] }.to_h
        doc.deep_merge!(additional_doc) if additional_doc
        index.update_document(document_type, record.id, doc)
      end

      def destroy_document(id)
        index.destroy_document(document_type, id)
      end

      def find(id)
        if id.is_a?(Array)
          query = {query: {ids: {values: id, type: document_type}}, size: id.length}
          index.search(query, type: document_type)
        else
          index.find(document_type, id)
        end
      end

      def import(records)
        index.bulk :index, document_type, records.map(&:as_indexed_json)
      end

      def search(query, options={})
        options[:type] = document_type
        index.search(query, options)
      end
    end
  end
end