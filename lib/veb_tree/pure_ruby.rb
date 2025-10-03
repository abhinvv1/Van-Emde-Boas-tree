# frozen_string_literal: true

require 'set'

module VebTree
  class PureRuby
    attr_reader :universe_size, :size
    
    NIL_VALUE = -1
    
    def initialize(universe_size)
      raise ArgumentError, "Universe size must be positive" if universe_size <= 0
      
      @universe_size = next_power_of_2(universe_size)
      warn "Universe size #{universe_size} rounded up to #{@universe_size}" if @universe_size != universe_size
      
      @size = 0
      @min = NIL_VALUE
      @max = NIL_VALUE
      
      # Base case
      if @universe_size <= 2
        @base_case = true
        return
      end
      
      @base_case = false
      
      # Calculate sqrt
      log_u = Math.log2(@universe_size).to_i
      @sqrt_size = 1 << (log_u / 2)
      @num_clusters = @universe_size / @sqrt_size
      
      # Lazy allocation
      @clusters = Array.new(@num_clusters)
      @summary = nil
    end
    
    def insert(key)
      validate_key(key)
      return false if include?(key)
      
      # Empty tree
      if @min == NIL_VALUE
        @min = @max = key
        @size += 1
        return true
      end
      
      # Base case
      if @base_case
        @min = key if key < @min
        @max = key if key > @max
        @size += 1
        return true
      end
      
      # Ensure key is not min
      if key < @min
        key, @min = @min, key
      end
      
      @max = key if key > @max
      
      # Recursive insert
      h = high(key)
      l = low(key)
      
      # Lazy create cluster
      @clusters[h] ||= PureRuby.new(@sqrt_size)
      
      # If cluster was empty, update summary
      if @clusters[h].min == NIL_VALUE
        @summary ||= PureRuby.new(@num_clusters)
        @summary.insert(h)
        @clusters[h].instance_variable_set(:@min, l)
        @clusters[h].instance_variable_set(:@max, l)
        @clusters[h].instance_variable_set(:@size, 1)
      else
        @clusters[h].insert(l)
      end
      
      @size += 1
      true
    end
    
    def delete(key)
      return false unless include?(key)
      
      # Base case
      if @base_case
        if key == @min && key == @max
          @min = @max = NIL_VALUE
        elsif key == @min
          @min = @max
        else
          @max = @min
        end
        @size -= 1
        return true
      end
      
      # Only one element
      if @size == 1
        @min = @max = NIL_VALUE
        @size = 0
        return true
      end
      
      # Replace min with successor if deleting min
      if key == @min
        first_cluster = @summary.min
        key = index(first_cluster, @clusters[first_cluster].min)
        @min = key
      end
      
      # Recursive delete
      h = high(key)
      l = low(key)
      
      @clusters[h].delete(l) if @clusters[h]
      
      # If cluster is empty, remove from summary
      if @clusters[h] && @clusters[h].min == NIL_VALUE
        @summary.delete(h)
        @clusters[h] = nil
        
        # Update max if necessary
        if key == @max
          summary_max = @summary.max
          if summary_max == NIL_VALUE
            @max = @min
          else
            @max = index(summary_max, @clusters[summary_max].max)
          end
        end
      elsif key == @max && @clusters[h]
        @max = index(h, @clusters[h].max)
      end
      
      @size -= 1
      true
    end
    
    def include?(key)
      return false if key < 0 || key >= @universe_size
      return true if key == @min || key == @max
      return false if @base_case
      
      h = high(key)
      @clusters[h] && @clusters[h].include?(low(key))
    end
    alias member? include?
    
    def min
      @min == NIL_VALUE ? nil : @min
    end
    
    def max
      @max == NIL_VALUE ? nil : @max
    end
    
    def successor(key)
      return nil if @min == NIL_VALUE
      
      # Base case
      if @base_case
        return @min if key < @min
        return @max if key < @max
        return nil
      end
      
      return @min if key < @min
      
      h = high(key)
      l = low(key)
      
      # Check same cluster
      if @clusters[h] && l < @clusters[h].max
        offset = @clusters[h].successor(l)
        return index(h, offset)
      end
      
      # Next cluster
      succ_cluster = @summary.successor(h)
      return nil if succ_cluster == NIL_VALUE
      
      offset = @clusters[succ_cluster].min
      index(succ_cluster, offset)
    end
    
    def predecessor(key)
      return nil if @max == NIL_VALUE
      
      # Base case
      if @base_case
        return @max if key > @max
        return @min if key > @min
        return nil
      end
      
      return @max if key > @max
      
      h = high(key)
      l = low(key)
      
      # Check same cluster
      if @clusters[h] && l > @clusters[h].min
        offset = @clusters[h].predecessor(l)
        return index(h, offset)
      end
      
      # Previous cluster
      pred_cluster = @summary.predecessor(h)
      return @min if pred_cluster == NIL_VALUE && key > @min
      return nil if pred_cluster == NIL_VALUE
      
      offset = @clusters[pred_cluster].max
      index(pred_cluster, offset)
    end
    
    def empty?
      @size == 0
    end
    
    def clear
      @min = @max = NIL_VALUE
      @size = 0
      unless @base_case
        @summary&.clear
        @clusters.fill(nil)
      end
      self
    end
    
    def each
      return enum_for(:each) unless block_given?
      
      current = @min
      while current && current != NIL_VALUE
        yield current
        break if current == @max
        current = successor(current)
      end
      
      self
    end
    
    def to_a
      each.to_a
    end
    
    private
    
    def high(x)
      x / @sqrt_size
    end
    
    def low(x)
      x % @sqrt_size
    end
    
    def index(high, low)
      high * @sqrt_size + low
    end
    
    def validate_key(key)
      raise ArgumentError, "Key must be non-negative" if key < 0
      raise ArgumentError, "Key #{key} exceeds universe size #{@universe_size}" if key >= @universe_size
    end
    
    def next_power_of_2(n)
      return 1 if n <= 1
      2 ** (Math.log2(n).ceil)
    end
  end
end
