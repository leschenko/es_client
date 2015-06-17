# EsClient

[![Build Status](https://travis-ci.org/leschenko/es_client.png?branch=master)](https://travis-ci.org/leschenko/es_client)
[![Dependency Status](https://gemnasium.com/leschenko/es_client.png)](https://gemnasium.com/leschenko/es_client)

This elasticsearch client is just all you need to index and search your data with persistent http connection.
It don't tend to wrap [elasticsearch](http://elasticsearch.org) dsl into ruby style dsl.
[Excon](https://github.com/excon/excon) used for http staff.
There is adapter for ActiveRecord models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'es_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install es_client

## Usage

Create index:
```ruby
index = EsClient::Index.new('products')
index.create
```

Add document to index:
```ruby
index.save_document('product', 1, {id: 1, name: 'Table', sku: '123'})
```

Fetch document:
```ruby
index.find('product', 1)
```

Add few document with one query i.e. bulk index:
```ruby
index.bulk(:index, 'product', [{id: 2, name: 'Chair'}, {id: 2, name: 'Lamp'}])
```

And, of course, search:
```ruby
index.search(query: {query_string: {query: 'table OR chair'}}).decoded
```

### Configuration options
```ruby
EsClient.setup do |config|
  # Elasticsearch host
  # config.host = 'http://localhost:9200'

  # Log file path
  config.log_path = Rails.root.join('log', 'elasticsearch.log')

  # Log level (successful requests logged in debug)
  # config.logger.level = ::Logger::Severity::INFO unless Rails.env.development?

  # Log options, should be set to false in production for better performance
  #   `log_binary` - log binary data in bulk requests
  #   `log_response` - log response json, can be disabled in production
  #   `pretty` - pretty generate json in logs
  # config.logger_options = {log_binary: true, log_response: true, pretty: true}

  # Application wide index prefix
  # config.index_prefix = 'my_app_name_here'

  # Enable indexing callbacks
  # config.callbacks_enabled = true

  # Options passed to http client initializer (Excon currently)
  # config.http_client_options = {persistent: true}
end
```

### With ActiveRecord model:

Include EsClient modules:
```ruby
class User
  include ::EsClient::ActiveRecord::Glue
  include ::EsClient::ActiveRecord::Shortcuts
end
```

Create index:
```ruby
User.es_client.index.create
```

Indexing performed on `save` and `destroy` callbacks:
```ruby
user = User.create(name: 'alex')
```

Fetch record elasticsearch document:
```ruby
user.es_doc
```

Search:
```ruby
User.es_client.search(query: {query_string: {query: 'table OR chair'}})
```

Reindex all your data:
```ruby
User.es_client_reindex
```

Or with progressbar (requires `ruby-progressbar` gem):
```ruby
User.es_client_reindex_with_progress
```


## Contributing

1. Fork it ( https://github.com/leschenko/es_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
