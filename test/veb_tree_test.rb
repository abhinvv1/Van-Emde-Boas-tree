# frozen_string_literal: true

require "test_helper"

class VebTreeTest < Minitest::Test
  def setup
    @tree = VebTree::Tree.new(128)
  end
  
  def test_version
    refute_nil VebTree::VERSION
  end
  
  def test_native_extension_loaded
    assert VebTree::NATIVE_EXTENSION_LOADED, "Native extension should be loaded"
  end
  
  # Constructor tests
  
  def test_creates_tree_with_power_of_2
    tree = VebTree::Tree.new(16)
    assert_equal 16, tree.universe_size
  end
  
  def test_rounds_up_to_power_of_2
    tree = VebTree::Tree.new(100)
    assert_equal 128, tree.universe_size
  end
  
  def test_rejects_zero_universe
    assert_raises(ArgumentError) { VebTree::Tree.new(0) }
  end
  
  # Insert tests
  
  def test_insert_single_element
    assert @tree.insert(5)
    assert_equal 1, @tree.size
  end
  
  def test_insert_duplicate_returns_false
    @tree.insert(5)
    refute @tree.insert(5)
    assert_equal 1, @tree.size
  end
  
  def test_insert_multiple_elements
    [5, 10, 3, 7, 20].each { |k| @tree.insert(k) }
    assert_equal 5, @tree.size
  end
  
  def test_insert_out_of_range_raises
    assert_raises(ArgumentError) { @tree.insert(200) }
  end
  
  # Contains tests
  
  def test_contains_inserted_element
    @tree.insert(42)
    assert @tree.include?(42)
  end
  
  def test_not_contains_missing_element
    refute @tree.include?(99)
  end
  
  def test_member_alias
    @tree.insert(42)
    assert @tree.member?(42)
  end
  
  # Delete tests
  
  def test_delete_existing_element
    @tree.insert(42)
    assert @tree.delete(42)
    assert_equal 0, @tree.size
    refute @tree.include?(42)
  end
  
  def test_delete_nonexistent_returns_false
    refute @tree.delete(99)
  end
  
  def test_delete_multiple_elements
    [5, 10, 3, 7].each { |k| @tree.insert(k) }
    assert @tree.delete(5)
    assert @tree.delete(10)
    assert_equal 2, @tree.size
    assert @tree.include?(3)
    assert @tree.include?(7)
  end
  
  # Min/Max tests
  
  def test_min_on_empty_tree
    assert_nil @tree.min
  end
  
  def test_max_on_empty_tree
    assert_nil @tree.max
  end
  
  def test_min_returns_smallest
    [10, 5, 20, 3, 15].each { |k| @tree.insert(k) }
    assert_equal 3, @tree.min
  end
  
  def test_max_returns_largest
    [10, 5, 20, 3, 15].each { |k| @tree.insert(k) }
    assert_equal 20, @tree.max
  end
  
  def test_min_max_single_element
    @tree.insert(42)
    assert_equal 42, @tree.min
    assert_equal 42, @tree.max
  end
  
  # Successor tests
  
  def test_successor_basic
    [3, 5, 7, 10, 15, 20].each { |k| @tree.insert(k) }
    assert_equal 7, @tree.successor(5)
    assert_equal 10, @tree.successor(7)
  end
  
  def test_successor_of_max_is_nil
    [3, 5, 10].each { |k| @tree.insert(k) }
    assert_nil @tree.successor(10)
  end
  
  def test_successor_of_missing_element
    [3, 10, 20].each { |k| @tree.insert(k) }
    assert_equal 10, @tree.successor(5)
  end
  
  def test_successor_on_empty_tree
    assert_nil @tree.successor(5)
  end
  
  # Predecessor tests
  
  def test_predecessor_basic
    [3, 5, 7, 10, 15, 20].each { |k| @tree.insert(k) }
    assert_equal 7, @tree.predecessor(10)
    assert_equal 5, @tree.predecessor(7)
  end
  
  def test_predecessor_of_min_is_nil
    [3, 5, 10].each { |k| @tree.insert(k) }
    assert_nil @tree.predecessor(3)
  end
  
  def test_predecessor_of_missing_element
    [3, 10, 20].each { |k| @tree.insert(k) }
    assert_equal 10, @tree.predecessor(15)
  end
  
  def test_predecessor_on_empty_tree
    assert_nil @tree.predecessor(5)
  end
  
  # Empty/Clear tests
  
  def test_empty_on_new_tree
    assert @tree.empty?
  end
  
  def test_not_empty_after_insert
    @tree.insert(5)
    refute @tree.empty?
  end
  
  def test_clear_empties_tree
    [5, 10, 15].each { |k| @tree.insert(k) }
    @tree.clear
    assert @tree.empty?
    assert_equal 0, @tree.size
  end
  
  # Enumeration tests
  
  def test_each_iterates_in_order
    [10, 5, 20, 3, 15].each { |k| @tree.insert(k) }
    result = []
    @tree.each { |k| result << k }
    assert_equal [3, 5, 10, 15, 20], result
  end
  
  def test_to_a_returns_sorted_array
    [10, 5, 20, 3, 15].each { |k| @tree.insert(k) }
    assert_equal [3, 5, 10, 15, 20], @tree.to_a
  end
  
  def test_enumerable_methods
    [5, 10, 15, 20].each { |k| @tree.insert(k) }
    assert_equal 4, @tree.count
    assert_equal [10, 20, 30, 40], @tree.map { |x| x * 2 }
    assert_equal [15, 20], @tree.select { |x| x > 12 }
  end
  
  # Stress tests
  
  def test_large_insertions
    tree = VebTree::Tree.new(10000)
    elements = (0...1000).to_a.shuffle
    elements.each { |e| tree.insert(e) }
    assert_equal 1000, tree.size
    assert_equal 0, tree.min
    assert_equal 999, tree.max
  end
  
  def test_correctness_with_random_operations
    tree = VebTree::Tree.new(1000)
    inserted = Set.new
    
    # Random inserts
    100.times do
      key = rand(1000)
      tree.insert(key)
      inserted.add(key)
    end
    
    # Verify all inserted elements are present
    inserted.each do |key|
      assert tree.include?(key), "Key #{key} should be in tree"
    end
    
    # Verify to_a matches Set
    assert_equal inserted.to_a.sort, tree.to_a
  end
  
  def test_successor_predecessor_consistency
    [10, 20, 30, 40, 50].each { |k| @tree.insert(k) }
    
    # successor(predecessor(x)) == x for x in tree (except min)
    [20, 30, 40, 50].each do |x|
      pred = @tree.predecessor(x)
      assert_equal x, @tree.successor(pred)
    end
    
    # predecessor(successor(x)) == x for x in tree (except max)
    [10, 20, 30, 40].each do |x|
      succ = @tree.successor(x)
      assert_equal x, @tree.predecessor(succ)
    end
  end
end
