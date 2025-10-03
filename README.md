# VebTree - Van Emde Boas Tree

[![Tests](https://github.com/abhinvv1/Van-Emde-Boas-tree/workflows/Tests/badge.svg)](https://github.com/abhinvv1/Van-Emde-Boas-tree/actions)
[![Gem Version](https://badge.fury.io/rb/veb_tree.svg)](https://badge.fury.io/rb/veb_tree)

A high-performance **Van Emde Boas (vEB) tree** implementation for Ruby with a C++17 core.  
Provides **O(log log U)** time complexity for integer set operations, making it exponentially faster than balanced BSTs for many workloads.

---

## ✨ Features

- ⚡ **Blazing Fast** — `O(log log U)` operations for insert, delete, search, successor, and predecessor  
- 🖥 **Native Performance** — core implemented in **C++17**  
- 🧑‍💻 **Simple API** — clean, idiomatic Ruby interface  
- 🧩 **Memory Efficient** — lazy cluster allocation to minimize space usage  
- ✅ **Battle Tested** — comprehensive test suite included  

---

## 📦 Installation

### Requirements
- **Ruby**: 2.7 or higher  
- **C++17** compatible compiler:  
  - **Linux**: GCC 7+ or Clang 5+  
  - **macOS**: Xcode Command Line Tools  
  - **Windows**: MinGW-w64 or MSVC 2017+  

### Install via RubyGems
```bash
gem install veb_tree
```

### Install from Source
```bash
git clone https://github.com/yourusername/veb_tree.git
cd veb_tree
bundle install
rake compile
rake test
gem build veb_tree.gemspec
gem install veb_tree-*.gem
```

---

## 🚀 Quick Start

```ruby
require 'veb_tree'

# Create a tree with universe size (rounded to next power of 2)
tree = VebTree::Tree.new(1000)  # Actual size: 1024

# Insert elements
tree.insert(42)
tree.insert(100)
tree.insert(7)
tree.insert(500)

# Membership check
tree.include?(42)   # => true
tree.include?(99)   # => false

# Min/Max
tree.min  # => 7
tree.max  # => 500

# Successor / Predecessor
tree.successor(42)    # => 100
tree.predecessor(100) # => 42

# Size & emptiness
tree.size   # => 4
tree.empty? # => false

# Iterate in sorted order
tree.each { |key| puts key }
# Output: 7, 42, 100, 500

# Convert to array
tree.to_a  # => [7, 42, 100, 500]

# Delete elements
tree.delete(42)  # => true
tree.delete(42)  # => false (already removed)

# Clear all elements
tree.clear
```

---

## 📖 API Reference

### Constructor
```ruby
VebTree::Tree.new(universe_size)
```

- **universe_size (Integer)** — maximum value that can be stored (exclusive).  
  Automatically rounded up to the next power of 2.  
- **Returns**: `VebTree::Tree` instance  
- **Raises**: `ArgumentError` if universe_size ≤ 0  

**Example:**
```ruby
tree = VebTree::Tree.new(100) 
tree.universe_size  # => 128
```

---

### Core Operations

#### Insert
```ruby
tree.insert(key) → Boolean
```
- Inserts a key.  
- **Time**: O(log log U)  
- Returns `true` if inserted, `false` if already present.  

#### Delete
```ruby
tree.delete(key) → Boolean
```
- Removes a key.  
- **Time**: O(log log U)  
- Returns `true` if deleted, `false` if not found.  

#### Membership
```ruby
tree.include?(key) → Boolean
tree.member?(key)  # alias
```
- Checks if key exists.  
- **Time**: O(log log U)  

#### Min / Max
```ruby
tree.min → Integer or nil
tree.max → Integer or nil
```
- Returns smallest or largest key.  
- **Time**: O(1)  

#### Successor / Predecessor
```ruby
tree.successor(key)    → Integer or nil
tree.predecessor(key)  → Integer or nil
```
- Finds next higher or next lower key.  
- **Time**: O(log log U)  

---

### Utility Methods

- `tree.size` → number of elements (**O(1)**)  
- `tree.empty?` → true/false (**O(1)**)  
- `tree.universe_size` → current universe size  
- `tree.clear` → removes all elements  

---

### Enumeration

The tree includes `Enumerable`, so all Ruby iteration helpers work:

```ruby
tree.each { |key| puts key }
tree.to_a       # => [7, 42, 100, 500]
tree.map { |x| x * 2 }  # => [14, 84, 200, 1000]
tree.select { |x| x > 50 } # => [100, 500]
tree.count  # => 4
```

---

## 📊 Performance

| Operation   | vEB Tree | Balanced BST |
|-------------|----------|--------------|
| Insert      | O(log log U) | O(log n) |
| Delete      | O(log log U) | O(log n) |
| Search      | O(log log U) | O(log n) |
| Successor   | O(log log U) | O(log n) |
| Predecessor | O(log log U) | O(log n) |
| Min/Max     | O(1)         | O(log n) |

- **U** = universe size (max key)  
- **n** = number of stored elements  

vEB trees are best for **bounded integer sets** with frequent `successor/predecessor/min/max` queries.  

⚠️ Avoid when:  
- Universe size is **huge (> 2^24)**  
- Need arbitrary objects (only integers supported)  
- Extremely memory constrained  

---

## 💾 Space Complexity

- **Theoretical**: O(U)  
- **Optimized** with lazy allocation: only used clusters consume memory  

**Practical Usage:**  
- Universe `2^16` (65K): ~hundreds of KB  
- Universe `2^20` (1M): ~few MB  
- Universe `2^24` (16M): ~tens of MB  

---

## ⚠️ Thread Safety

This implementation is **NOT thread-safe**.  
For concurrency, wrap operations with a `Mutex`:  

```ruby
require 'thread'

tree = VebTree::Tree.new(1000)
mutex = Mutex.new

mutex.synchronize do
  tree.insert(42)
end
```

---

## 🛑 Error Handling

```ruby
tree = VebTree::Tree.new(0)      # ArgumentError: Universe size must be > 0
tree.insert(-1)                  # ArgumentError: Key must be non-negative
tree.insert(200)                 # ArgumentError: Key exceeds universe size

tree.include?(999)               # => false
tree.successor(999)              # => nil
```

---

## 🧪 Examples

### Range Query Simulation
```ruby
tree = VebTree::Tree.new(10000)

100.times { tree.insert(rand(10000)) }

current = tree.successor(999)  # first ≥ 1000
result = []
while current && current <= 2000
  result << current
  current = tree.successor(current)
end
```

### K-th Smallest Element
```ruby
def kth_smallest(tree, k)
  current = tree.min
  (k - 1).times do
    return nil unless current
    current = tree.successor(current)
  end
  current
end

tree = VebTree::Tree.new(1000)
[5, 10, 3, 50].each { |x| tree.insert(x) }

kth_smallest(tree, 2)  # => 5
```

---

## 🔧 Development

```bash
# Clone repo
git clone https://github.com/yourusername/veb_tree.git
cd veb_tree

# Install dependencies
bundle install

# Compile extension
rake compile

# Run tests
rake test

# Clean build
rake clean
```

---

## 🤝 Contributing

Bug reports and pull requests are welcome at:  
👉 [https://github.com/abhinvv1/Van-Emde-Boas-tree](https://github.com/abhinvv1/Van-Emde-Boas-tree)

---

## 📜 License

This gem is available as open source under the **MIT License**.  

---

## 📚 References & Credits

- Based on the **Van Emde Boas tree** described by *Peter van Emde Boas (1975)*  
- *Cormen, T. H., et al. (2009). Introduction to Algorithms (3rd ed.), Chapter 20*  

---

## 🗒️ Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history.
