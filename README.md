# VebTree - Van Emde Boas Tree

A high-performance Van Emde Boas (vEB) tree implementation for Ruby with a C++ core, providing **O(log log U)** time complexity for integer set operations.

## Features

- **Blazing Fast**: O(log log U) operations for insert, delete, search, successor, and predecessor
- **Native Performance**: Core algorithm implemented in C++17
- **Simple API**: Clean, idiomatic Ruby interface
- **Memory Efficient**: Lazy cluster allocation
- **Battle Tested**: Comprehensive test suite

## Installation

### Requirements

- Ruby 2.7 or higher
- C++17 compatible compiler:
  - **Linux**: GCC 7+ or Clang 5+
  - **macOS**: Xcode Command Line Tools
  - **Windows**: MinGW-w64 or MSVC 2017+

### Install via RubyGems
```bash
gem install veb_tree
```

## Install from Source
```
git clone https://github.com/yourusername/veb_tree.git
cd veb_tree
bundle install
rake compile
rake test
gem build veb_tree.gemspec
gem install veb_tree-*.gem
```

### Quick Start
```
require 'veb_tree'

# Create a tree with universe size (will round to next power of 2)
tree = VebTree::Tree.new(1000)  # Actual size: 1024

# Insert elements
tree.insert(42)
tree.insert(100)
tree.insert(7)
tree.insert(500)

# Check membership - O(log log U)
tree.include?(42)   # => true
tree.include?(99)   # => false

# Min/Max - O(1)
tree.min  # => 7
tree.max  # => 500

# Successor/Predecessor - O(log log U)
tree.successor(42)    # => 100
tree.predecessor(100) # => 42

# Size and empty check
tree.size     # => 4
tree.empty?   # => false

# Iterate in sorted order
tree.each { |key| puts key }
# Output: 7, 42, 100, 500

# Convert to array
tree.to_a  # => [7, 42, 100, 500]

# Delete elements
tree.delete(42)  # => true
tree.delete(42)  # => false (not present)

# Clear all elements
tree.clear
```

### API Reference
```VebTree::Tree.new(universe_size)```

Creates a new Van Emde Boas tree.
- universe_size (Integer): Maximum value that can be stored (exclusive). Will be 
- rounded up to the next power of 2.
- Returns: New VebTree::Tree instance
- Raises: ArgumentError if universe_size is not positive

#### Example
```
tree = VebTree::Tree.new(100)  # Actual universe: 128
tree.universe_size  # => 128
```
