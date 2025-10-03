# frozen_string_literal: true

require "mkmf"

# Check for C++ compiler
unless find_executable("g++") || find_executable("clang++")
  abort "C++ compiler not found. Please install a C++ compiler."
end

# Determine the C++ compiler
if RUBY_PLATFORM =~ /darwin/
  RbConfig::MAKEFILE_CONFIG["CXX"] = "clang++"
  RbConfig::MAKEFILE_CONFIG["LDSHAREDXX"] = "clang++ -dynamic -bundle"
  
  if RUBY_VERSION < "3.0"
    $CXXFLAGS << " -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION"
    $CXXFLAGS << " -Wno-error=implicit-function-declaration"
  end
else
  RbConfig::MAKEFILE_CONFIG["CXX"] = ENV["CXX"] || "g++"
end

# C++17 standard
$CXXFLAGS << " -std=c++17 -Wall -Wextra -O2"

# Platform-specific settings
case RUBY_PLATFORM
when /darwin/
  $CXXFLAGS << " -stdlib=libc++"
  $LDFLAGS << " -stdlib=libc++"
when /linux/
  $LDFLAGS << " -lstdc++"
when /mingw|mswin/
  $CXXFLAGS << " -static-libgcc -static-libstdc++"
end

# Debug flags if requested
if ENV["DEBUG"] == "1"
  $CXXFLAGS << " -g -O0 -DDEBUG"
else
  $CXXFLAGS << " -DNDEBUG"
end

create_makefile("veb_tree/veb_tree")
