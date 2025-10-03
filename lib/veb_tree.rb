# frozen_string_literal: true

require_relative "veb_tree/version"

module VebTree
  class Error < StandardError; end
  
  # Load the native extension
  begin
    require_relative "veb_tree/veb_tree"
    NATIVE_EXTENSION_LOADED = true
  rescue LoadError => e
    raise Error, <<~MSG
      Failed to load VebTree native extension!
      
      Error: #{e.message}
      
      VebTree requires a C++17 compatible compiler to build the native extension.
      
      Requirements:
        - Linux: GCC 7+ or Clang 5+
        - macOS: Xcode Command Line Tools
        - Windows: MinGW-w64 or MSVC 2017+
      
      To install:
        1. Install a C++ compiler for your platform
        2. Run: gem install veb_tree
      
      For more help, see: https://github.com/yourusername/veb_tree
    MSG
  end
end
