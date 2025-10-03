#!/usr/bin/env ruby
# frozen_string_literal: true

puts "=" * 60
puts "VebTree Installation Test"
puts "=" * 60
puts

# Test 1: Can require the gem?
print "Test 1: Loading VebTree gem... "
begin
  require 'veb_tree'
  puts "✓ SUCCESS"
rescue LoadError => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 2: Check version
print "Test 2: Checking version... "
begin
  version = VebTree::VERSION
  puts "✓ SUCCESS (v#{version})"
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 3: Native extension loaded?
print "Test 3: Native extension loaded... "
if VebTree::NATIVE_EXTENSION_LOADED
  puts "✓ SUCCESS"
else
  puts "✗ FAILED: Native extension not loaded"
  exit 1
end

# Test 4: Create tree
print "Test 4: Creating tree... "
begin
  tree = VebTree::Tree.new(100)
  puts "✓ SUCCESS (universe: #{tree.universe_size})"
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 5: Basic operations
print "Test 5: Insert elements... "
begin
  [5, 10, 3, 7, 20, 15].each { |k| tree.insert(k) }
  if tree.size == 6
    puts "✓ SUCCESS (size: #{tree.size})"
  else
    puts "✗ FAILED: Expected size 6, got #{tree.size}"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 6: Contains check
print "Test 6: Membership test... "
begin
  if tree.include?(5) && tree.include?(10) && !tree.include?(99)
    puts "✓ SUCCESS"
  else
    puts "✗ FAILED: Membership test incorrect"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 7: Min/Max
print "Test 7: Min/Max... "
begin
  if tree.min == 3 && tree.max == 20
    puts "✓ SUCCESS (min: #{tree.min}, max: #{tree.max})"
  else
    puts "✗ FAILED: Expected min=3, max=20, got min=#{tree.min}, max=#{tree.max}"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 8: Successor
print "Test 8: Successor... "
begin
  succ = tree.successor(7)
  if succ == 10
    puts "✓ SUCCESS (successor of 7 is #{succ})"
  else
    puts "✗ FAILED: Expected successor of 7 to be 10, got #{succ}"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 9: Predecessor
print "Test 9: Predecessor... "
begin
  pred = tree.predecessor(10)
  if pred == 7
    puts "✓ SUCCESS (predecessor of 10 is #{pred})"
  else
    puts "✗ FAILED: Expected predecessor of 10 to be 7, got #{pred}"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 10: To array
print "Test 10: To array... "
begin
  arr = tree.to_a
  expected = [3, 5, 7, 10, 15, 20]
  if arr == expected
    puts "✓ SUCCESS (#{arr.inspect})"
  else
    puts "✗ FAILED: Expected #{expected.inspect}, got #{arr.inspect}"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 11: Delete
print "Test 11: Delete element... "
begin
  deleted = tree.delete(7)
  if deleted && !tree.include?(7) && tree.size == 5
    puts "✓ SUCCESS"
  else
    puts "✗ FAILED: Delete did not work correctly"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 12: Clear
print "Test 12: Clear tree... "
begin
  tree.clear
  if tree.empty? && tree.size == 0
    puts "✓ SUCCESS"
  else
    puts "✗ FAILED: Clear did not work correctly"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 13: Large dataset
print "Test 13: Large dataset (1000 elements)... "
begin
  large_tree = VebTree::Tree.new(10000)
  elements = (0...1000).to_a.shuffle
  elements.each { |e| large_tree.insert(e) }
  
  if large_tree.size == 1000 && large_tree.min == 0 && large_tree.max == 999
    puts "✓ SUCCESS"
  else
    puts "✗ FAILED: Large dataset test failed"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

# Test 14: Enumerable
print "Test 14: Enumerable support... "
begin
  small_tree = VebTree::Tree.new(100)
  [10, 20, 30].each { |k| small_tree.insert(k) }
  
  doubled = small_tree.map { |x| x * 2 }
  if doubled == [20, 40, 60]
    puts "✓ SUCCESS"
  else
    puts "✗ FAILED: Enumerable test failed"
    exit 1
  end
rescue => e
  puts "✗ FAILED: #{e.message}"
  exit 1
end

puts
puts "=" * 60
puts "✓ ALL TESTS PASSED!"
puts "VebTree is working correctly!"
puts "=" * 60
