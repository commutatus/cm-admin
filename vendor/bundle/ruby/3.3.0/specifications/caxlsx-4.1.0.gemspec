# -*- encoding: utf-8 -*-
# stub: caxlsx 4.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "caxlsx".freeze
  s.version = "4.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/caxlsx/caxlsx/issues", "changelog_uri" => "https://github.com/caxlsx/caxlsx/blob/master/CHANGELOG.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/caxlsx/caxlsx" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Randy Morgan".freeze, "Jurriaan Pruis".freeze]
  s.date = "2024-02-28"
  s.description = "xlsx spreadsheet generation with charts, images, automated column width, customizable styles and full schema validation. Axlsx helps you create beautiful Office Open XML Spreadsheet documents (Excel, Google Spreadsheets, Numbers, LibreOffice) without having to understand the entire ECMA specification. Check out the README for some examples of how easy it is. Best of all, you can validate your xlsx file before serialization so you know for sure that anything generated is going to load on your client's machine.\n".freeze
  s.email = "noel@peden.biz".freeze
  s.homepage = "https://github.com/caxlsx/caxlsx".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Excel OOXML (xlsx) with charts, styles, images and autowidth columns.".freeze

  s.installed_by_version = "3.5.11".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<htmlentities>.freeze, ["~> 4.3".freeze, ">= 4.3.4".freeze])
  s.add_runtime_dependency(%q<marcel>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.10".freeze, ">= 1.10.4".freeze])
  s.add_runtime_dependency(%q<rubyzip>.freeze, [">= 1.3.0".freeze, "< 3".freeze])
end
