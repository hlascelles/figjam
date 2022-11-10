# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name    = "figjam"
  spec.version = "1.2.0"

  spec.authors       = ["Harry Lascelles"]
  spec.email         = ["harry@harrylascelles.com"]
  spec.summary       = "ENV configuration for ruby using yaml files"
  spec.description   = "ENV configuration for ruby using hierarchical environment yaml files"
  spec.homepage      = "https://github.com/hlascelles/figjam"
  spec.license       = "MIT"
  spec.metadata      = {
    "homepage_uri"      => "https://github.com/hlascelles/figjam",
    "documentation_uri" => "https://github.com/hlascelles/figjam",
    "changelog_uri"     => "https://github.com/hlascelles/figjam/blob/master/CHANGELOG.md",
    "source_code_uri"   => "https://github.com/hlascelles/figjam/",
    "bug_tracker_uri"   => "https://github.com/hlascelles/figjam/issues",
    "rubygems_mfa_required" => "true",
  }

  spec.add_dependency "thor", ">= 0.14.0", "< 2"

  spec.add_development_dependency "bundler", ">= 1.7.0", "< 3"
  spec.add_development_dependency "rake", ">= 10.4.0", "< 14"

  spec.files = Dir["{bin,lib}/**/*"] + ["README.md"]
  spec.require_paths = ["lib"]
  spec.test_files = spec.files.grep(/^spec/)
  spec.executables << "figjam"
end
