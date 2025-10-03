# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-10-03

### Added
- Fix compatibility issues for ruby 2.7 and macos

## [0.1.0] - 2025-10-03

### Added
- Initial release of VebTree gem
- Full Van Emde Boas tree implementation in C++17
- Ruby bindings for all core operations
- O(log log U) performance for insert, delete, search, successor, predecessor
- O(1) performance for min/max queries
- Lazy cluster allocation for memory efficiency
- Enumerable support for iteration
- Comprehensive test suite
- Full API documentation

### Features
- `VebTree::Tree.new(universe_size)` - Constructor with automatic power-of-2 rounding
- `#insert(key)` - Insert element
- `#delete(key)` - Delete element
- `#include?(key)` / `#member?(key)` - Membership test
- `#min` / `#max` - Get minimum/maximum elements (O(1))
- `#successor(key)` - Get next larger element
- `#predecessor(key)` - Get next smaller element
- `#size` - Get number of elements
- `#empty?` - Check if tree is empty
- `#clear` - Remove all elements
- `#each` - Iterate over elements in sorted order
- `#to_a` - Convert to sorted array

### Platform Support
- Ruby 2.7+ on Linux (GCC 7+, Clang 5+)
- Ruby 2.7+ on macOS (Xcode Command Line Tools)
- Ruby 2.7+ on Windows (MinGW-w64, MSVC 2017+)
