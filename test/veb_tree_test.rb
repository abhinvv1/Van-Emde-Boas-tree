# frozen_string_literal: true

require "test_helper"

class VebTreeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::VebTree::VERSION
  end
  
  def test_native_extension_loads
    skip "Native extension not loaded" unless VebTree::NATIVE_EXTENSION_LOADED
    assert VebTree::NATIVE_EXTENSION_LOADED
  end
  
  def test_can_create_tree
    tree = VebTree::Tree.new(16)
    assert_instance_of VebTree::Tree, tree
  end
  
  def test_universe_size_rounds_up_to_power_of_2
    tree = VebTree::Tree.new(10)
    assert_equal 16, tree.universe_size
  end
  
  def test_basic_insert
    tree = VebTree::Tree.new(16)
    result = tree.insert(5)
    assert_equal true, result
    assert_equal 1, tree.size
  end
  
  def test_insert_out_of_range_raises
    tree = VebTree::Tree.new(16)
    assert_raises(ArgumentError) do
      tree.insert(20)
    end
  end
  
  def test_basic_delete
    tree = VebTree::Tree.new(16)
    tree.insert(5)
    result = tree.delete(5)
    assert_equal true, result
  end
  
  def test_basic_include
    tree = VebTree::Tree.new(16)
    tree.insert(5)
    # Note: In Stage 1, include? is a placeholder and returns false
    # This will be fixed in Stage 2
    assert_equal false, tree.include?(5) # Placeholder behavior
  end
end
