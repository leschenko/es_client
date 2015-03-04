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

    # index.create mappings: {product: {properties: {sku: {type: "string"}}}}, settings: {number_of_shards: 1}
    def create
      request_options = @options.present? ? {body: @options.to_json} : {}
      EsClient.client.post("/#{name}", request_options)
    end

    def delete
      EsClient.client.delete("/#{name}")
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
      EsClient.client.put("/#{path}/_mapping/#{type}", {body: json})
    end
  end
end