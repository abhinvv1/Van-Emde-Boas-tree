# Van-Emde-Boas-tree

## VebTree

Van Emde Boas (vEB) tree implementation for Ruby, providing O(log log U) time complexity for integer set operations.

### Features

- **Fast Operations**: O(log log U) time for insert, delete, search, successor, and predecessor
- **C++ Core**: Native C++ implementation for maximum performance
- **Pure Ruby Fallback**: Automatic fallback when native extensions can't be compiled
- **Thread-Aware**: Clear documentation of thread-safety characteristics
- **Well-Tested**: Comprehensive test suite with CI integration
- **Production Ready**: Clean API, error handling, and extensive documentation

### Installation

Add this line to your application's Gemfile:
```ruby
gem 'veb_tree'