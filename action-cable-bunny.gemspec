# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "action_cable/bunny/version"

Gem::Specification.new do |spec|
  spec.name          = "action-cable-bunny"
  spec.version       = ActionCable::Bunny::VERSION
  spec.authors       = ["Kyle Welsby"]
  spec.email         = ["kyle@mekyle.com"]

  spec.summary       = "RabbitMQ adapter for ActionCable using bunny gem"
  spec.description   = "RabbitMQ adapter for ActionCable using bunny gem"
  spec.homepage      = "https://github.com/kylewelsby/action-cable-bunny"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/kylewelsby/action-cable-bunny"
    spec.metadata["changelog_uri"] = "https://github.com/kylewelsby/action-cable-bunny/releases"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "actioncable", "~> 5.2.3"
  spec.add_dependency "bunny", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.68"
end
