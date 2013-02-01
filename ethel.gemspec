# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ethel/version'

Gem::Specification.new do |gem|
  gem.name          = "ethel"
  gem.version       = Ethel::VERSION
  gem.authors       = ["Jeremy Stephens"]
  gem.email         = ["jeremy.f.stephens@vanderbilt.edu"]
  gem.description   = %q{Ethel is an ORM-agnostic library of ETL (extract-transform-load) utilities}
  gem.summary       = %q{ORM-agnostic ETL (extract-transform-load) utilities}
  gem.homepage      = "https://github.com/coupler/ethel"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
