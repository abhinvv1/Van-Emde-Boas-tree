require './lib/veb_tree/pure_ruby'

tree = VebTree::PureRuby.new(100)
puts "Created PureRuby tree with universe size: #{tree.universe_size}"

tree.insert(5)
tree.insert(10)
tree.insert(3)

puts "Min: #{tree.min}, Max: #{tree.max}"
puts "Elements: #{tree.to_a.inspect}"
puts "Successor of 5: #{tree.successor(5)}"
puts "Predecessor of 10: #{tree.predecessor(10)}"

puts "✓ Pure Ruby implementation works!"
