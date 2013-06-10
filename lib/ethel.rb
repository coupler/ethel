require 'csv'
require 'bigdecimal'

require 'ethel/version'
require 'ethel/field'
require 'ethel/source'
require 'ethel/operation'
require 'ethel/target'
require 'ethel/migration'
require 'ethel/util'

module Ethel
  class InvalidFieldType < Exception; end
end
