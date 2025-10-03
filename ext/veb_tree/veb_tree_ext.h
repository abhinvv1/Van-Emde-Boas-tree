#ifndef VEB_TREE_EXT_H
#define VEB_TREE_EXT_H

#include <ruby.h>
#include <cstdint>
#include <memory>
#include <stdexcept>

// Forward declarations
extern "C" {
    void Init_veb_tree();
}

namespace VebTree {

/**
 * Van Emde Boas Tree implementation
 * 
 * This is a placeholder for Stage 2. Currently just validates
 * that the build system works correctly.
 */
class VEBTree {
public:
    explicit VEBTree(uint64_t universe_size);
    ~VEBTree() = default;

    // Placeholder methods - will be fully implemented in Stage 2
    bool insert(uint64_t key);
    bool remove(uint64_t key);
    bool contains(uint64_t key) const;
    
    uint64_t size() const { return size_; }
    uint64_t universe_size() const { return universe_; }

private:
    uint64_t universe_;
    uint64_t size_;
};

/**
 * Ruby wrapper class for VEBTree
 */
class TreeWrapper {
public:
    static void define_class(VALUE module);
    
private:
    // Ruby method wrappers
    static VALUE rb_alloc(VALUE klass);
    static void rb_free(void* ptr);
    static VALUE rb_initialize(VALUE self, VALUE universe_size);
    static VALUE rb_insert(VALUE self, VALUE key);
    static VALUE rb_delete(VALUE self, VALUE key);
    static VALUE rb_include(VALUE self, VALUE key);
    static VALUE rb_size(VALUE self);
    static VALUE rb_universe_size(VALUE self);
    
    // Helper to get C++ object from Ruby object
    static VEBTree* get_tree(VALUE self);
};

} // namespace VebTree

#endif // VEB_TREE_EXT_H
