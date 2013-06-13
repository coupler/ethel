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
    def const_missing(name)
      if Ethel.const_defined?(name)
        Ethel.const_get(name)
      else
        super
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
