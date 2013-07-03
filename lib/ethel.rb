require 'csv'
require 'bigdecimal'

require 'ethel/version'
require 'ethel/field'
require 'ethel/dataset'
require 'ethel/reader'
require 'ethel/writer'
require 'ethel/operation'
require 'ethel/migration'
require 'ethel/util'

module Ethel
  class InvalidFieldType < Exception; end
  class InvalidFieldName < Exception; end
  class NonexistentField < Exception; end
  class InvalidRow < Exception; end
end
