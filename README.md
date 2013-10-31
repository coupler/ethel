# Ethel

Ethel is an ETL data management tool for Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'ethel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ethel

## Usage

Ethel has three main components: readers, operations, and writers. Readers read
from a data source, operations transform the data, and writers output the
transformed data into a different form. A set of instructions to convert a
dataset is called a migration.

Reader and writer modules are logically organized into _adapters_. Ethel has
two built-in adapters: CSV and memory. The CSV adapter provides input and
output of delimited text files. The memory adapter is a thin wrapper on top of
regular Ruby objects. Additional adapters can be implemented as separate
libraries.

There are a few operations available:
* add/remove/rename/select fields
* cast
* merge
* update

Example:

```ruby
require 'ethel'

read_options = {:type => 'csv', :file => 'foo.csv'}
write_options = {:type => 'csv', :file => 'bar.csv'}
Ethel.migrate(read_options, write_options) do |m|
  m.cast('foo', :integer)
  m.cast('bar', :string)
  m.update('baz') do |row|
    row['qux'] * 5
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
