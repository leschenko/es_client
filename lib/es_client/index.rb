module EsClient
  class Index

    attr_reader :name, :settings

    def initialize(name, options={})
      @name = name
      @options = options
    end

    def exists?
      EsClient.client.head("/#{name}").success?
    end

    def recreate
      delete
      create
    end

    # index.create mappings: {product: {properties: {sku: {type: "string"}}}}, settings: {number_of_shards: 1}
    def create
      request_options = @options.present? ? {body: @options.to_json} : {}
      EsClient.client.post("/#{name}", request_options)
    end

    def delete
      EsClient.client.delete("/#{name}")
    end

    def refresh
      EsClient.client.post("/#{name}/_refresh")
    end

    def get_settings
      EsClient.client.get("/#{name}/_settings").decoded[name]['settings']
    end

    def get_mapping
      EsClient.client.get("/#{name}/_mapping").decoded[name]['mappings']
    end

    # index.put_mapping 'product', properties: {sku: {type: "string"}}
    def put_mapping(type, mapping)
      json = {type => mapping}.to_json
      EsClient.client.put("/#{name}/_mapping/#{type}", body: json)
    end

    def store(type, document)
      EsClient.client.post("/#{name}/#{type}/#{document[:id]}", body: document.to_json)
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
            payload << {doc: document}
        end
      end
      EsClient.client.post("/#{name}/#{type}/_bulk", body: "\n" + payload.map(&:to_json).join("\n") + "\n")
    end
  end
end