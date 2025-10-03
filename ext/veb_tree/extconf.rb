# frozen_string_literal: true

require "mkmf"

# Check for C++ compiler
unless find_executable("g++") || find_executable("clang++")
  abort "C++ compiler not found. Please install a C++ compiler."
end

# Set C++ compiler
RbConfig::MAKEFILE_CONFIG["CXX"] = ENV["CXX"] || "g++"

# C++17 standard
$CXXFLAGS << " -std=c++17 -Wall -Wextra -O3"

# Enable optimizations
$CXXFLAGS << " -march=native" if ENV["NATIVE_ARCH"] == "1"

# Debug flags if requested
if ENV["DEBUG"] == "1"
  $CXXFLAGS << " -g -O0 -DDEBUG"
else
  $CXXFLAGS << " -DNDEBUG"
end

# Platform-specific settings
case RUBY_PLATFORM
when /darwin/
  # macOS specific flags
  $CXXFLAGS << " -stdlib=libc++"
when /linux/
  # Linux specific flags
  $LDFLAGS << " -lstdc++"
when /mingw|mswin/
  # Windows specific flags
  $CXXFLAGS << " -static-libgcc -static-libstdc++"
end

# Create Makefile
create_makefile("veb_tree/veb_tree")
