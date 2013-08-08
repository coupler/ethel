require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'mocha/setup'
require 'tempfile'

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ethel'

class SequenceHelper
  include Mocha::API

  def initialize(name)
    @seq = sequence(name)
  end

  def <<(expectation)
    expectation.in_sequence(@seq)
  end
end

module ConstantsHelper
  module ClassMethods
    def scope(mod)
      @scope = []
      mod.name.split("::").inject(Object) do |mod, name|
        child = mod.const_get(name)
        @scope << child
        child
      end
    end

    def const_missing(name)
      if @scope
        @scope.reverse_each do |mod|
          if mod.const_defined?(name)
            return mod.const_get(name)
          end
        end
      end
      super
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

module IntegrationHelper
  module ClassMethods
    IO_TYPES = %w{memory csv}

    def io_test(desc, *combinations, &block)
      if combinations.empty?
        combinations = IO_TYPES.product(IO_TYPES)
      end
      combinations.each do |(read_type, write_type)|
        desc2 = "#{desc} (#{read_type} to #{write_type})"
        test(desc2, &block)
        method_name = added_methods.last
        attribute(:read_type, read_type, {}, method_name)
        attribute(:write_type, write_type, {}, method_name)
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def get_reader(type, data)
    case type
    when 'memory'
      Ethel::Adapters::Memory::Reader.new(:data => data)
    when 'csv'
      Ethel::Readers::CSV.new(:string => data)
    else
      raise "invalid reader type: #{type.inspect}"
    end
  end

  def get_writer(type)
    case type
    when 'memory'
      Ethel::Adapters::Memory::Writer.new
    when 'csv'
      Ethel::Writers::CSV.new(:string => true)
    else
      raise "invalid writer type: #{type.inspect}"
    end
  end

  def convert_rows(rows, from, to)
    if from == to
      rows
    else
      reader = get_reader(from, rows)
      writer = get_writer(to)
      Ethel::Migration.new(reader, writer).run
      writer.data
    end
  end

  def migrate(data, expected, read_type = self[:read_type], write_type = self[:write_type])
    rows = convert_rows(data, 'memory', read_type)
    reader = get_reader(read_type, rows)
    writer = get_writer(write_type)
    migration = Ethel::Migration.new(reader, writer)
    yield migration
    migration.run

    actual = convert_rows(writer.data, write_type, 'memory')
    assert_equal expected, actual
  end
end
