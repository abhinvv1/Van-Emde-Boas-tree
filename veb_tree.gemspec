# frozen_string_literal: true

require_relative "lib/veb_tree/version"

Gem::Specification.new do |spec|
  spec.name = "veb_tree"
  spec.version = VebTree::VERSION
  spec.authors = ["pixelcaliber"]
  spec.email = ["abhinav.1e4@gmail.com"]

  spec.summary = "High-performance Van Emde Boas tree for integer sets with O(log log U) operations"
  spec.description = <<~DESC
    VebTree is a production-quality Van Emde Boas tree implementation providing 
    O(log log U) time complexity for insert, delete, search, successor, and 
    predecessor operations on integer sets. The core algorithm is implemented 
    in C++17 for maximum performance with an idiomatic Ruby API.
    
    Perfect for applications requiring fast integer set operations, range queries,
    and successor/predecessor lookups within a bounded universe.
  DESC
  
  spec.homepage = "https://github.com/abhinvv1/Van-Emde-Boas-tree"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/veb_tree"
  spec.metadata["github_repo"] = "ssh://github.com/abhinvv1/Van-Emde-Boas-tree"

  # Specify which files should be added to the gem
  spec.files = Dir.glob(%w[
    lib/**/*.rb
    ext/**/*.{cpp,h,rb}
    LICENSE
    README.md
    CHANGELOG.md
  ])
  
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/veb_tree/extconf.rb"]

  # Runtime dependencies - NONE for production gem
  
  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
