# EsClient

This elasticsearch client is just all you need to index and search your data with persistent http connection.
It don't tend to wrap [elasticsearch](http://elasticsearch.org) dsl into ruby style dsl.
[Excon](https://github.com/excon/excon) used for http staff.

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
  index = EsClient::Index.new('products', mappings: {product: {properties: {sku: {type: 'string'}}}}, settings: {number_of_shards: 1})
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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/es_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
