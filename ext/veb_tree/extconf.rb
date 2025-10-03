# frozen_string_literal: true

require "mkmf"

# Check for C++ compiler
unless find_executable("g++") || find_executable("clang++")
  abort "C++ compiler not found. Please install a C++ compiler."
end

# Determine the C++ compiler
if RUBY_PLATFORM =~ /darwin/
  # macOS: Force use of clang++
  RbConfig::MAKEFILE_CONFIG["CXX"] = "clang++"
  RbConfig::MAKEFILE_CONFIG["LDSHAREDXX"] = "clang++ -dynamic -bundle"
else
  # Linux/Windows: Use g++ or whatever is available
  RbConfig::MAKEFILE_CONFIG["CXX"] = ENV["CXX"] || "g++"
end

# C++17 standard
$CXXFLAGS << " -std=c++17 -Wall -Wextra -O2"

# Platform-specific settings
case RUBY_PLATFORM
when /darwin/
  # macOS specific flags
  $CXXFLAGS << " -stdlib=libc++"
  $LDFLAGS << " -stdlib=libc++"
when /linux/
  # Linux specific flags
  $LDFLAGS << " -lstdc++"
when /mingw|mswin/
  # Windows specific flags
  $CXXFLAGS << " -static-libgcc -static-libstdc++"
end

# Debug flags if requested
if ENV["DEBUG"] == "1"
  $CXXFLAGS << " -g -O0 -DDEBUG"
else
  $CXXFLAGS << " -DNDEBUG"
end

# Create Makefile
create_makefile("veb_tree/veb_tree")
