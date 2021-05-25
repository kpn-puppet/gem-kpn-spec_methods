lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kpn_spec_methods/version'

Gem::Specification.new do |spec|
  spec.name          = 'kpn_spec_methods'
  spec.version       = KpnSpecMethods::VERSION
  spec.authors       = ['kpn']
  spec.email         = ['noreply@kpn.com']

  spec.summary       = 'This gem contains the spec acceptance helper methods that were previously located in spec_helper_acceptance_methods.rb'
  spec.homepage      = 'https://github.com/kpn-puppet/gem-kpn-spec_methods'
  spec.license       = 'Apache-2.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
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
  spec.files = Dir['lib/**/*.rb']

  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency 'rspec', '~> 3.0'
end
