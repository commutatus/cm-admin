# -*- encoding: utf-8 -*-
# stub: caxlsx_rails 0.6.3 ruby lib

Gem::Specification.new do |s|
  s.name = "caxlsx_rails".freeze
  s.version = "0.6.3".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Noel Peden".freeze]
  s.date = "2022-03-08"
  s.description = "Caxlsx_Rails provides an Caxlsx renderer so you can move all your spreadsheet code from your controller into view files. Partials are supported so you can organize any code into reusable chunks (e.g. cover sheets, common styling, etc.) You can use it with acts_as_caxlsx, placing the to_xlsx call in a view and adding ':package => xlsx_package' to the parameter list. Now you can keep your controllers thin!".freeze
  s.email = ["noel@peden.biz".freeze]
  s.homepage = "https://github.com/caxlsx/caxlsx_rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "A simple rails plugin to provide an xlsx renderer using the caxlsx gem.".freeze

  s.installed_by_version = "3.5.11".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 3.1".freeze])
  s.add_runtime_dependency(%q<caxlsx>.freeze, [">= 3.0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<roo>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubyzip>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<growl>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rb-fsevent>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<coveralls>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry-nav>.freeze, [">= 0".freeze])
end
