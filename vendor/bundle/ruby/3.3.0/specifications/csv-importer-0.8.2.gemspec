# -*- encoding: utf-8 -*-
# stub: csv-importer 0.8.2 ruby lib

Gem::Specification.new do |s|
  s.name = "csv-importer".freeze
  s.version = "0.8.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Philippe Creux".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-08-02"
  s.email = ["pcreux@gmail.com".freeze]
  s.homepage = "https://github.com/pcreux/csv-importer".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "CSV Import for humans".freeze

  s.installed_by_version = "3.5.11".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<virtus>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.3.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<activemodel>.freeze, ["~> 5".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0".freeze])
end
