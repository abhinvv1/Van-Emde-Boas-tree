#include "veb_tree_ext.h"
#include <cmath>
#include <stdexcept>

namespace VebTree {

// ============================================================================
// VEBTree Implementation (Placeholder for Stage 1)
// ============================================================================

VEBTree::VEBTree(uint64_t universe_size) 
    : universe_(universe_size), size_(0) {
    
    if (universe_size == 0) {
        throw std::invalid_argument("Universe size must be greater than 0");
    }
    
    // For Stage 1, just validate and store the universe size
    // Full implementation will come in Stage 2
}

bool VEBTree::insert(uint64_t key) {
    if (key >= universe_) {
        throw std::out_of_range("Key exceeds universe size");
    }
    // Placeholder - always succeeds for now
    size_++;
    return true;
}

bool VEBTree::remove(uint64_t key) {
    if (key >= universe_) {
        return false;
    }
    // Placeholder
    if (size_ > 0) size_--;
    return true;
}

bool VEBTree::contains(uint64_t key) const {
    if (key >= universe_) {
        return false;
    }
    // Placeholder - always returns false
    return false;
}

// ============================================================================
// Ruby Wrapper Implementation
// ============================================================================

// Ruby type wrapping
static const rb_data_type_t veb_tree_type = {
    "VebTree::Tree",
    {
        nullptr, // dmark - no Ruby objects to mark
        [](void* ptr) { delete static_cast<VEBTree*>(ptr); }, // dfree
        nullptr, // dsize
    },
    nullptr, nullptr,
    RUBY_TYPED_FREE_IMMEDIATELY
};

VEBTree* TreeWrapper::get_tree(VALUE self) {
    VEBTree* tree;
    TypedData_Get_Struct(self, VEBTree, &veb_tree_type, tree);
    return tree;
}

VALUE TreeWrapper::rb_alloc(VALUE klass) {
    return TypedData_Wrap_Struct(klass, &veb_tree_type, nullptr);
}

VALUE TreeWrapper::rb_initialize(VALUE self, VALUE universe_size) {
    Check_Type(universe_size, T_FIXNUM);
    
    uint64_t u = NUM2ULL(universe_size);
    
    if (u == 0) {
        rb_raise(rb_eArgError, "Universe size must be greater than 0");
    }
    
    // Round up to next power of 2
    uint64_t rounded = 1ULL << (uint64_t)std::ceil(std::log2((double)u));
    
    if (rounded != u) {
        rb_warn("Universe size %llu rounded up to next power of 2: %llu", u, rounded);
    }
    
    VEBTree* tree = nullptr;
    try {
        tree = new VEBTree(rounded);
    } catch (const std::exception& e) {
        rb_raise(rb_eRuntimeError, "Failed to create VEB tree: %s", e.what());
    }
    
    RTYPEDDATA_DATA(self) = tree;
    return self;
}

VALUE TreeWrapper::rb_insert(VALUE self, VALUE key) {
    Check_Type(key, T_FIXNUM);
    
    VEBTree* tree = get_tree(self);
    uint64_t k = NUM2ULL(key);
    
    try {
        bool inserted = tree->insert(k);
        return inserted ? Qtrue : Qfalse;
    } catch (const std::out_of_range& e) {
        rb_raise(rb_eArgError, "Key out of range: %s", e.what());
    } catch (const std::exception& e) {
        rb_raise(rb_eRuntimeError, "Insert failed: %s", e.what());
    }
    
    return Qfalse;
}

VALUE TreeWrapper::rb_delete(VALUE self, VALUE key) {
    Check_Type(key, T_FIXNUM);
    
    VEBTree* tree = get_tree(self);
    uint64_t k = NUM2ULL(key);
    
    try {
        bool deleted = tree->remove(k);
        return deleted ? Qtrue : Qfalse;
    } catch (const std::exception& e) {
        rb_raise(rb_eRuntimeError, "Delete failed: %s", e.what());
    }
    
    return Qfalse;
}

VALUE TreeWrapper::rb_include(VALUE self, VALUE key) {
    Check_Type(key, T_FIXNUM);
    
    VEBTree* tree = get_tree(self);
    uint64_t k = NUM2ULL(key);
    
    return tree->contains(k) ? Qtrue : Qfalse;
}

VALUE TreeWrapper::rb_size(VALUE self) {
    VEBTree* tree = get_tree(self);
    return ULL2NUM(tree->size());
}

VALUE TreeWrapper::rb_universe_size(VALUE self) {
    VEBTree* tree = get_tree(self);
    return ULL2NUM(tree->universe_size());
}

void TreeWrapper::define_class(VALUE module) {
    VALUE cTree = rb_define_class_under(module, "Tree", rb_cObject);
    
    rb_define_alloc_func(cTree, rb_alloc);
    rb_define_method(cTree, "initialize", RUBY_METHOD_FUNC(rb_initialize), 1);
    rb_define_method(cTree, "insert", RUBY_METHOD_FUNC(rb_insert), 1);
    rb_define_method(cTree, "delete", RUBY_METHOD_FUNC(rb_delete), 1);
    rb_define_method(cTree, "include?", RUBY_METHOD_FUNC(rb_include), 1);
    rb_define_method(cTree, "size", RUBY_METHOD_FUNC(rb_size), 0);
    rb_define_method(cTree, "universe_size", RUBY_METHOD_FUNC(rb_universe_size), 0);
}

} // namespace VebTree

// ============================================================================
// Extension Initialization
// ============================================================================

extern "C" void Init_veb_tree() {
    VALUE mVebTree = rb_define_module("VebTree");
    VebTree::TreeWrapper::define_class(mVebTree);
    
    // Version constant will be set from Ruby side
}
