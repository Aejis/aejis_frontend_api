lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frontend_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'frontend_api'
  spec.version       = FrontendApi::VERSION
  spec.authors       = ['Aleksey Dashkevych']
  spec.email         = ['jester@aejis.eu']
  spec.summary       = 'Frontend API'
  spec.description   = 'API for frontend'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'json_matchers', '= 0.7.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-gitlab-security'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'sqlite3'

  spec.add_runtime_dependency 'sequel', '~> 5.9'
end
