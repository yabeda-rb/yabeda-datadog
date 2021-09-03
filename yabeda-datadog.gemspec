# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yabeda/datadog/version"

Gem::Specification.new do |spec|
  spec.name          = "yabeda-datadog"
  spec.version       = Yabeda::Datadog::VERSION
  spec.authors       = ["Dmitry Shvetsov <@shvetsovdm>"]
  spec.email         = ["shvetsovdm@gmail.com"]

  spec.summary       = "DataDog adapter for reporting metrics from Yabeda suite"
  spec.description = <<~DESCRIPTION
    Adapter for reporting custom metrics from Yabeda to DataDog.
  DESCRIPTION
  spec.homepage      = "https://github.com/shvetsovdm/yabeda-datadog"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "anyway_config", ">= 1.0"
  spec.add_dependency "dogapi"
  spec.add_dependency "dogstatsd-ruby", "!= 5.0.0", "!= 5.0.1"
  spec.add_dependency "yabeda"

  spec.add_development_dependency "appraisal", "~> 2.4"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry", "~> 0.13"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
