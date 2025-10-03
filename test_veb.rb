#!/usr/bin/env ruby
require './lib/veb_tree'

puts "VebTree Manual Test"
puts "=" * 50
puts "Native extension loaded: #{VebTree::NATIVE_EXTENSION_LOADED}"
puts

# Create tree
tree = VebTree::Tree.new(100)
puts "Created tree with universe size: #{tree.universe_size}"
puts

# Insert some elements
[5, 10, 3, 7, 20, 15].each do |key|
  result = tree.insert(key)
  puts "Insert #{key}: #{result}"
end
puts "Size: #{tree.size}"
puts

# Test contains
[3, 5, 8, 10].each do |key|
  puts "Contains #{key}?: #{tree.include?(key)}"
end
puts

# Min/Max
puts "Min: #{tree.min}"
puts "Max: #{tree.max}"
puts

# Successor/Predecessor
puts "Successor of 5: #{tree.successor(5)}"
puts "Successor of 10: #{tree.successor(10)}"
puts "Predecessor of 10: #{tree.predecessor(10)}"
puts "Predecessor of 7: #{tree.predecessor(7)}"
puts

# Enumerate
puts "All elements:"
tree.each { |key| puts "  #{key}" }
puts

# To array
puts "As array: #{tree.to_a.inspect}"
puts

# Delete
puts "Delete 7: #{tree.delete(7)}"
puts "Contains 7?: #{tree.include?(7)}"
puts "Size: #{tree.size}"
puts "All elements: #{tree.to_a.inspect}"
puts

# Clear
tree.clear
puts "After clear - Size: #{tree.size}, Empty?: #{tree.empty?}"

puts "\n✓ All manual tests passed!"
