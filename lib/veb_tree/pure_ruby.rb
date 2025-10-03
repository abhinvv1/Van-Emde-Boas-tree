# frozen_string_literal: true

module VebTree
  # Pure Ruby fallback implementation of Van Emde Boas Tree
  # This is significantly slower than the C++ version but allows
  # the gem to work in environments where native extensions cannot be compiled.
  #
  # Performance: O(log log U) operations but with higher constant factors
  class PureRuby
    attr_reader :universe_size, :size
    
    # Initialize a new VEB tree
    # @param universe_size [Integer] Maximum value that can be stored (exclusive)
    def initialize(universe_size)
      raise ArgumentError, "Universe size must be positive" if universe_size <= 0
      
      # Round up to next power of 2
      @universe_size = next_power_of_2(universe_size)
      warn "Universe size #{universe_size} rounded up to #{@universe_size}" if @universe_size != universe_size
      
      @size = 0
      @min = nil
      @max = nil
      
      # For Stage 1, use a simple Set as placeholder
      # Full vEB structure will be implemented in Stage 2
      @data = Set.new
    end
    
    # Insert a key into the tree
    # @param key [Integer] Key to insert
    # @return [Boolean] true if inserted, false if already present
    def insert(key)
      validate_key(key)
      
      if @data.add?(key)
        @size += 1
        @min = key if @min.nil? || key < @min
        @max = key if @max.nil? || key > @max
        true
      else
        false
      end
    end
    
    # Delete a key from the tree
    # @param key [Integer] Key to delete
    # @return [Boolean] true if deleted, false if not present
    def delete(key)
      return false if key < 0 || key >= @universe_size
      
      if @data.delete?(key)
        @size -= 1
        recalculate_min_max if @size > 0
        true
      else
        false
      end
    end
    
    # Check if a key is in the tree
    # @param key [Integer] Key to check
    # @return [Boolean] true if present
    def include?(key)
      return false if key < 0 || key >= @universe_size
      @data.include?(key)
    end
    alias member? include?
    
    # Get the minimum key
    # @return [Integer, nil] Minimum key or nil if empty
    def min
      @min
    end
    
    # Get the maximum key
    # @return [Integer, nil] Maximum key or nil if empty
    def max
      @max
    end
    
    # Find the successor of a key
    # @param key [Integer] Key to find successor of
    # @return [Integer, nil] Smallest key > key, or nil if none exists
    def successor(key)
      return nil if key >= @max
      @data.select { |k| k > key }.min
    end
    
    # Find the predecessor of a key
    # @param key [Integer] Key to find predecessor of
    # @return [Integer, nil] Largest key < key, or nil if none exists
    def predecessor(key)
      return nil if key <= @min
      @data.select { |k| k < key }.max
    end
    
    # Check if tree is empty
    # @return [Boolean] true if empty
    def empty?
      @size == 0
    end
    
    # Clear all elements
    def clear
      @data.clear
      @size = 0
      @min = nil
      @max = nil
      self
    end
    
    # Enumerate all keys in ascending order
    def each(&block)
      return enum_for(:each) unless block_given?
      @data.sort.each(&block)
    end
    
    # Convert to array
    # @return [Array<Integer>] Sorted array of all keys
    def to_a
      @data.sort
    end
    
    private
    
    def validate_key(key)
      raise ArgumentError, "Key must be non-negative" if key < 0
      raise ArgumentError, "Key #{key} exceeds universe size #{@universe_size}" if key >= @universe_size
    end
    
    def next_power_of_2(n)
      return 1 if n <= 1
      2 ** (Math.log2(n).ceil)
    end
    
    def recalculate_min_max
      if @size == 0
        @min = @max = nil
      else
        @min = @data.min
        @max = @data.max
      end
    end
  end
end
