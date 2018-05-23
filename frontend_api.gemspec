lib = File.expand_path('../lib', __FILE__)
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

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3.13'
  spec.add_development_dependency 'pry', '~> 0.11.3'
  spec.add_development_dependency 'sinatra', '~> 2.0.1'
  spec.add_development_dependency 'rack-test', '~> 0.8.3'
  spec.add_development_dependency 'json_matchers', '~> 0.7.3'

  spec.add_runtime_dependency 'sequel', '~> 5.6.0'
end
