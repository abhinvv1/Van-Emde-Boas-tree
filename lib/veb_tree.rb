# frozen_string_literal: true

require_relative "veb_tree/version"

module VebTree
  class Error < StandardError; end
  
  # Try to load the native extension
  begin
    require_relative "veb_tree/veb_tree"
    NATIVE_EXTENSION_LOADED = true
  rescue LoadError => e
    warn "VebTree: Failed to load native extension (#{e.message}), falling back to pure Ruby implementation"
    NATIVE_EXTENSION_LOADED = false
    require_relative "veb_tree/pure_ruby"
  end
  
  # Expose the Tree class at module level for convenience
  # This will be either the C++ version or pure Ruby version
  def self.Tree(*args)
    if NATIVE_EXTENSION_LOADED
      VebTree::Tree.new(*args)
    else
      VebTree::PureRuby.new(*args)
    end
  end
end
