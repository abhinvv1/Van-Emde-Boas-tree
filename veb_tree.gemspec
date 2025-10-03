# frozen_string_literal: true

require_relative "lib/veb_tree/version"

Gem::Specification.new do |spec|
  spec.name = "veb_tree"
  spec.version = VebTree::VERSION
  spec.authors = ["Your Name"]
  spec.email = ["your.email@example.com"]

  spec.summary = "Van Emde Boas tree implementation for fast integer set operations"
  spec.description = <<~DESC
    A production-quality Van Emde Boas tree implementation providing O(log log U) 
    time complexity for insert, delete, search, successor, and predecessor operations 
    on integer sets. Core algorithm implemented in C++ for performance with a pure 
    Ruby fallback.
  DESC
  spec.homepage = "https://github.com/yourusername/veb_tree"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/veb_tree"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*.rb
    ext/**/*.{cpp,h,rb}
    LICENSE
    README.md
    ARCHITECTURE.md
    CHANGELOG.md
  ])
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/veb_tree/extconf.rb"]

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "benchmark-ips", "~> 2.0"
  spec.add_development_dependency "yard", "~> 0.9"
end
