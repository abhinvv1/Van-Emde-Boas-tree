#ifndef VEB_TREE_EXT_H
#define VEB_TREE_EXT_H

#include <ruby.h>
#include <cstdint>
#include <memory>
#include <stdexcept>
#include <cmath>
#include <vector>
#include <limits>

extern "C" {
    void Init_veb_tree();
}

namespace VebTree {

/**
 * Van Emde Boas Tree - Full Implementation
 * 
 * Provides O(log log U) operations for integer sets
 * where U is the universe size (must be power of 2)
 */
class VEBTree {
public:
    // NIL sentinel value - must be public for TreeWrapper access
    static constexpr int64_t NIL = -1;
    
    explicit VEBTree(uint64_t universe_size);
    ~VEBTree() = default;

    // Core operations
    bool insert(uint64_t key);
    bool remove(uint64_t key);
    bool contains(uint64_t key) const;
    
    // Min/Max - O(1)
    int64_t min() const;
    int64_t max() const;
    
    // Successor/Predecessor - O(log log U)
    int64_t successor(uint64_t key) const;
    int64_t predecessor(uint64_t key) const;
    
    // Utility
    uint64_t size() const { return size_; }
    uint64_t universe_size() const { return universe_; }
    bool empty() const { return size_ == 0; }
    void clear();
    
    // For enumeration
    std::vector<uint64_t> to_vector() const;

private:
    uint64_t universe_;
    uint64_t size_;
    
    // vEB tree structure
    int64_t min_;
    int64_t max_;
    
    // For base case (universe <= 2)
    bool is_base_case_;
    
    // For recursive case
    std::unique_ptr<VEBTree> summary_;
    std::vector<std::unique_ptr<VEBTree>> clusters_;
    uint64_t sqrt_size_;
    
    // Helper functions
    uint64_t high(uint64_t x) const { return x / sqrt_size_; }
    uint64_t low(uint64_t x) const { return x % sqrt_size_; }
    uint64_t index(uint64_t high, uint64_t low) const { return high * sqrt_size_ + low; }
    
    void empty_insert(uint64_t key);
    void empty_delete();
};

/**
 * Ruby wrapper class
 */
class TreeWrapper {
public:
    static void define_class(VALUE module);
    
private:
    static VALUE rb_alloc(VALUE klass);
    static void rb_free(void* ptr);
    static VALUE rb_initialize(VALUE self, VALUE universe_size);
    static VALUE rb_insert(VALUE self, VALUE key);
    static VALUE rb_delete(VALUE self, VALUE key);
    static VALUE rb_include(VALUE self, VALUE key);
    static VALUE rb_size(VALUE self);
    static VALUE rb_universe_size(VALUE self);
    static VALUE rb_min(VALUE self);
    static VALUE rb_max(VALUE self);
    static VALUE rb_successor(VALUE self, VALUE key);
    static VALUE rb_predecessor(VALUE self, VALUE key);
    static VALUE rb_empty(VALUE self);
    static VALUE rb_clear(VALUE self);
    static VALUE rb_to_a(VALUE self);
    static VALUE rb_each(VALUE self);
    
    static VEBTree* get_tree(VALUE self);
};

} // namespace VebTree

#endif // VEB_TREE_EXT_H
