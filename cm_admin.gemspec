require_relative 'lib/cm_admin/version'

Gem::Specification.new do |spec|
  spec.name          = 'cm-admin'
  spec.version       = CmAdmin::VERSION
  spec.authors       = %w[Michael Anbazhagan Ayza Barath Pranav Mahaveer Austin]
  spec.email         = ['mkv@commutatus.com', 'anbublacky@gmail.com', 'ayza@commutatus.com', 'barath@commutatus.com', 'pranav@commutatus.com', 'mahaveer@commutatus.com', 'austin@commutatus.com']

  spec.summary       = 'CmAdmin is a robust gem designed to assist in creating admin panels for Rails applications'
  spec.description   = 'CmAdmin providing a streamlined and efficient solution for building customized admin panels within the context of Rails applications. Its robust features empower developers to effortlessly generate and manage administrative interfaces with precision and ease.'
  spec.homepage      = 'https://github.com/commutatus/cm-admin'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/commutatus/cm-admin'
  }
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'caxlsx_rails'
  spec.add_runtime_dependency 'cocoon', '~> 1.2.15'
  spec.add_runtime_dependency 'csv-importer', '~> 0.8.2'
  spec.add_runtime_dependency 'local_time', '~> 2.1.0'
  spec.add_runtime_dependency 'pagy', '~> 4.11.0'
  spec.add_runtime_dependency 'pundit', '~> 2.2.0'
  spec.add_runtime_dependency('rails', '>= 6.0')
  spec.add_runtime_dependency 'slim', '~> 4.1.0'
  spec.add_runtime_dependency 'webpacker', '~> 5.4.3'
  spec.add_runtime_dependency 'yard'
  spec.add_dependency 'importmap-rails'
end
