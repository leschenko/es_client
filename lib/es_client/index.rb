module EsClient
  class Index
    attr_reader :name, :options

    def initialize(name, options={})
      @name = build_name(name)
      @options = options
    end

    def build_name(name)
      return name unless EsClient.index_prefix
      "#{EsClient.index_prefix}_#{name}"
    end

    def exists?
      EsClient.client.head("/#{name}").success?
    end

    def recreate
      delete
      create
    end

    def create
      request_options = @options.present? ? {body: @options.to_json} : {}
      EsClient.client.post!("/#{name}", request_options)
    end

    def delete
      return unless exists?
      EsClient.client.delete!("/#{name}")
    end

    def refresh
      EsClient.client.post("/#{name}/_refresh")
    end

    def search(query, options={})
      http_options = options.slice(:query, :headers)
      http_options[:body] = query.to_json
      EsClient.client.get("/#{name}/#{options[:type]}/_search", http_options)
    end

    def get_settings
      EsClient.client.get("/#{name}/_settings").decoded[name]['settings']
    end

    def put_settings(settings)
      EsClient.client.put("/#{name}/_settings", body: settings.to_json)
    end

    def get_mapping
      EsClient.client.get("/#{name}/_mapping").decoded[name]['mappings']
    end

    def put_mapping(type, mapping)
      json = {type => mapping}.to_json
      EsClient.client.put("/#{name}/_mapping/#{type}", body: json)
    end

    def save_document(type, id, document)
      EsClient.client.post("/#{name}/#{type}/#{id}", body: document.to_json)
    end

    def update_document(type, id, document)
      EsClient.client.post("/#{name}/#{type}/#{id}/_update", body: {doc: document}.to_json)
    end

    def destroy_document(type, id)
      EsClient.client.delete("/#{name}/#{type}/#{id}")
    end

    def find(type, id)
      EsClient.client.get("/#{name}/#{type}/#{id}").decoded['_source']
    end

    def bulk(action, type, documents)
      payload = []
      documents.each do |document|
        payload << {action => {_index: name, _type: type, _id: document[:id]}}
        case action
          when :index
            payload << document
          when :update
            document.delete(:id)
            document_for_update = {doc: document}
            document_for_update.update(document[:bulk_options]) if document[:bulk_options]
            payload << document_for_update
        end
      end
      serialized_payload = "\n" + payload.map(&:to_json).join("\n") + "\n"
      EsClient.client.post("/#{name}/#{type}/_bulk", body: serialized_payload)
    end
  end
end