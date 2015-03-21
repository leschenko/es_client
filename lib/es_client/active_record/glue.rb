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

      def es_client_update(additional_doc=nil)
        return if new_record?
        es_client.update_document(self, additional_doc)
      end

      def es_client_update_fields(doc)
        return if new_record?
        es_client.update_fields(self, doc)
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

      module ClassMethods
        def es_client_reindex(options={})
          find_in_batches(options) do |batch|
            es_client.import(batch)
          end
        end

        def es_client_reindex_with_progress(options={})
          find_in_batches_with_progress(options) do |batch|
            es_client.import(batch)
          end
        end

        def find_in_batches_with_progress(options = {})
          unless defined? ProgressBar
            warn "Install 'ruby-progressbar' gem to use '#{__method__}' method"
            return
          end
          options[:batch_size] ||= 1000
          total = (count / options[:batch_size].to_f).ceil.succ
          title = options.delete(:name) || "#{name} batch_size:#{options[:batch_size]}"
          bar = ProgressBar.create(title: title, total: total, format: '%c of %C - %a %e |%b>>%i| %p%% %t')
          bar.progress_mark = '='
          find_in_batches(options) do |r|
            yield r
            bar.increment
          end
          bar.finish
        end unless respond_to?(:find_in_batches_with_progress)
      end
    end
  end
end