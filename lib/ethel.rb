require 'csv'
require 'bigdecimal'

require 'ethel/version'
require 'ethel/error'
require 'ethel/register'
require 'ethel/field'
require 'ethel/dataset'
require 'ethel/reader'
require 'ethel/writer'
require 'ethel/operation'
require 'ethel/migration'
require 'ethel/util'
require 'ethel/adapters'

module Ethel
  class InvalidFieldType < Exception; end
  class InvalidFieldName < Exception; end
  class NonexistentField < Exception; end
  class InvalidRow < Exception; end
  class InvalidChoice < Exception; end

  def self.migrate(read_options, write_options)
    reader = Reader[read_options[:type]].
      new(read_options.reject { |k, v| k == :type })
    writer = Writer[write_options[:type]].
      new(write_options.reject { |k, v| k == :type })
    migration = Migration.new(reader, writer)
    yield migration
    migration.run
    migration
  end
end
