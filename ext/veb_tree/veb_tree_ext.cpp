#include "veb_tree_ext.h"
#include <algorithm>

namespace VebTree {

// ============================================================================
// VEBTree Implementation
// ============================================================================

VEBTree::VEBTree(uint64_t universe_size) 
    : universe_(universe_size), 
      size_(0),
      min_(NIL), 
      max_(NIL),
      is_base_case_(universe_size <= 2),
      sqrt_size_(0) {
    
    if (universe_size == 0) {
        throw std::invalid_argument("Universe size must be greater than 0");
    }
    
    // Check if power of 2
    if ((universe_size & (universe_size - 1)) != 0) {
        throw std::invalid_argument("Universe size must be a power of 2");
    }
    
    if (!is_base_case_) {
        // Calculate sqrt of universe size
        sqrt_size_ = 1ULL << (uint64_t)(std::log2((double)universe_size) / 2.0);
        uint64_t num_clusters = universe_size / sqrt_size_;
        
        // Initialize clusters vector (but don't create trees yet - lazy allocation)
        clusters_.resize(num_clusters);
        
        // Summary tree
        summary_ = std::make_unique<VEBTree>(num_clusters);
    }
}

void VEBTree::empty_insert(uint64_t key) {
    min_ = max_ = static_cast<int64_t>(key);
    size_ = 1;
}

void VEBTree::empty_delete() {
    min_ = max_ = NIL;
    size_ = 0;
}

bool VEBTree::insert(uint64_t key) {
    if (key >= universe_) {
        throw std::out_of_range("Key exceeds universe size");
    }
    
    // Check if already present
    if (contains(key)) {
        return false;
    }
    
    // Empty tree
    if (min_ == NIL) {
        empty_insert(key);
        return true;
    }
    
    // Base case
    if (is_base_case_) {
        if (static_cast<int64_t>(key) < min_) {
            min_ = static_cast<int64_t>(key);
        }
        if (static_cast<int64_t>(key) > max_) {
            max_ = static_cast<int64_t>(key);
        }
        size_++;
        return true;
    }
    
    // Make sure key is not min/max
    if (static_cast<int64_t>(key) < min_) {
        uint64_t temp = static_cast<uint64_t>(min_);
        min_ = static_cast<int64_t>(key);
        key = temp;
    }
    
    if (static_cast<int64_t>(key) > max_) {
        max_ = static_cast<int64_t>(key);
    }
    
    // Recursive case
    uint64_t h = high(key);
    uint64_t l = low(key);
    
    // Lazy allocation of cluster
    if (!clusters_[h]) {
        clusters_[h] = std::make_unique<VEBTree>(sqrt_size_);
    }
    
    // If cluster was empty, update summary
    if (clusters_[h]->min_ == NIL) {
        summary_->insert(h);
        clusters_[h]->empty_insert(l);
    } else {
        clusters_[h]->insert(l);
    }
    
    size_++;
    return true;
}

bool VEBTree::remove(uint64_t key) {
    if (key >= universe_) {
        return false;
    }
    
    if (min_ == NIL) {
        return false; // Tree is empty
    }
    
    if (!contains(key)) {
        return false;
    }
    
    // Base case: universe size 2
    if (is_base_case_) {
        if (static_cast<int64_t>(key) == min_ && static_cast<int64_t>(key) == max_) {
            empty_delete();
        } else if (static_cast<int64_t>(key) == min_) {
            min_ = max_;
        } else {
            max_ = min_;
        }
        size_--;
        return true;
    }
    
    // Only one element
    if (size_ == 1) {
        empty_delete();
        return true;
    }
    
    // If deleting min, replace with successor
    if (static_cast<int64_t>(key) == min_) {
        int64_t first_cluster = summary_->min();
        key = index(static_cast<uint64_t>(first_cluster), static_cast<uint64_t>(clusters_[first_cluster]->min()));
        min_ = static_cast<int64_t>(key);
    }
    
    // Recursive delete
    uint64_t h = high(key);
    uint64_t l = low(key);
    
    if (clusters_[h]) {
        clusters_[h]->remove(l);
        
        // If cluster is now empty, remove from summary
        if (clusters_[h]->min_ == NIL) {
            summary_->remove(h);
            clusters_[h].reset(); // Free memory
            
            // Update max if we deleted it
            if (static_cast<int64_t>(key) == max_) {
                int64_t summary_max = summary_->max();
                if (summary_max == NIL) {
                    max_ = min_;
                } else {
                    max_ = index(static_cast<uint64_t>(summary_max), static_cast<uint64_t>(clusters_[summary_max]->max()));
                }
            }
        } else if (static_cast<int64_t>(key) == max_) {
            // Update max but cluster not empty
            max_ = index(h, static_cast<uint64_t>(clusters_[h]->max()));
        }
    }
    
    size_--;
    return true;
}

bool VEBTree::contains(uint64_t key) const {
    if (key >= universe_) {
        return false;
    }
    
    if (static_cast<int64_t>(key) == min_ || static_cast<int64_t>(key) == max_) {
        return true;
    }
    
    if (is_base_case_) {
        return false;
    }
    
    uint64_t h = high(key);
    uint64_t l = low(key);
    
    if (clusters_[h]) {
        return clusters_[h]->contains(l);
    }
    
    return false;
}

int64_t VEBTree::min() const {
    return min_;
}

int64_t VEBTree::max() const {
    return max_;
}

int64_t VEBTree::successor(uint64_t key) const {
    if (min_ == NIL) {
        return NIL;
    }
    
    // Base case
    if (is_base_case_) {
        if (static_cast<int64_t>(key) < min_) {
            return min_;
        } else if (static_cast<int64_t>(key) < max_) {
            return max_;
        } else {
            return NIL;
        }
    }
    
    // If key < min, min is the successor
    if (static_cast<int64_t>(key) < min_) {
        return min_;
    }
    
    uint64_t h = high(key);
    uint64_t l = low(key);
    
    // Check if successor is in same cluster
    if (clusters_[h] && static_cast<int64_t>(l) < clusters_[h]->max()) {
        int64_t offset = clusters_[h]->successor(l);
        return static_cast<int64_t>(index(h, static_cast<uint64_t>(offset)));
    }
    
    // Successor is in next cluster
    int64_t succ_cluster = summary_->successor(h);
    if (succ_cluster == NIL) {
        return NIL;
    }
    
    int64_t offset = clusters_[succ_cluster]->min();
    return static_cast<int64_t>(index(static_cast<uint64_t>(succ_cluster), static_cast<uint64_t>(offset)));
}

int64_t VEBTree::predecessor(uint64_t key) const {
    if (max_ == NIL) {
        return NIL;
    }
    
    // Base case
    if (is_base_case_) {
        if (static_cast<int64_t>(key) > max_) {
            return max_;
        } else if (static_cast<int64_t>(key) > min_) {
            return min_;
        } else {
            return NIL;
        }
    }
    
    // If key > max, max is the predecessor
    if (static_cast<int64_t>(key) > max_) {
        return max_;
    }
    
    uint64_t h = high(key);
    uint64_t l = low(key);
    
    // Check if predecessor is in same cluster
    if (clusters_[h] && static_cast<int64_t>(l) > clusters_[h]->min()) {
        int64_t offset = clusters_[h]->predecessor(l);
        return static_cast<int64_t>(index(h, static_cast<uint64_t>(offset)));
    }
    
    // Predecessor might be in previous cluster
    int64_t pred_cluster = summary_->predecessor(h);
    if (pred_cluster == NIL) {
        // Predecessor might be min
        if (static_cast<int64_t>(key) > min_) {
            return min_;
        }
        return NIL;
    }
    
    int64_t offset = clusters_[pred_cluster]->max();
    return static_cast<int64_t>(index(static_cast<uint64_t>(pred_cluster), static_cast<uint64_t>(offset)));
}

void VEBTree::clear() {
    min_ = max_ = NIL;
    size_ = 0;
    
    if (!is_base_case_) {
        summary_->clear();
        for (auto& cluster : clusters_) {
            cluster.reset();
        }
    }
}

std::vector<uint64_t> VEBTree::to_vector() const {
    std::vector<uint64_t> result;
    result.reserve(size_);
    
    if (min_ == NIL) {
        return result;
    }
    
    int64_t current = min_;
    while (current != NIL) {
        result.push_back(static_cast<uint64_t>(current));
        if (current == max_) break;
        current = successor(static_cast<uint64_t>(current));
    }
    
    return result;
}

// ============================================================================
// Ruby Wrapper Implementation
// ============================================================================

static const rb_data_type_t veb_tree_type = {
    "VebTree::Tree",
    {
        nullptr, // dmark
        [](void* ptr) { delete static_cast<VEBTree*>(ptr); }, // dfree
        nullptr, // dsize
        nullptr, // dcompact
    },
    nullptr, // parent
    nullptr, // data
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
        rb_warn("Universe size %llu rounded up to next power of 2: %llu", 
                (unsigned long long)u, (unsigned long long)rounded);
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

VALUE TreeWrapper::rb_min(VALUE self) {
    VEBTree* tree = get_tree(self);
    int64_t m = tree->min();
    return m == VEBTree::NIL ? Qnil : LL2NUM(m);
}

VALUE TreeWrapper::rb_max(VALUE self) {
    VEBTree* tree = get_tree(self);
    int64_t m = tree->max();
    return m == VEBTree::NIL ? Qnil : LL2NUM(m);
}

VALUE TreeWrapper::rb_successor(VALUE self, VALUE key) {
    Check_Type(key, T_FIXNUM);
    
    VEBTree* tree = get_tree(self);
    uint64_t k = NUM2ULL(key);
    
    int64_t succ = tree->successor(k);
    return succ == VEBTree::NIL ? Qnil : LL2NUM(succ);
}

VALUE TreeWrapper::rb_predecessor(VALUE self, VALUE key) {
    Check_Type(key, T_FIXNUM);
    
    VEBTree* tree = get_tree(self);
    uint64_t k = NUM2ULL(key);
    
    int64_t pred = tree->predecessor(k);
    return pred == VEBTree::NIL ? Qnil : LL2NUM(pred);
}

VALUE TreeWrapper::rb_empty(VALUE self) {
    VEBTree* tree = get_tree(self);
    return tree->empty() ? Qtrue : Qfalse;
}

VALUE TreeWrapper::rb_clear(VALUE self) {
    VEBTree* tree = get_tree(self);
    tree->clear();
    return self;
}

VALUE TreeWrapper::rb_to_a(VALUE self) {
    VEBTree* tree = get_tree(self);
    std::vector<uint64_t> elements = tree->to_vector();
    
    VALUE arr = rb_ary_new_capa(elements.size());
    for (uint64_t elem : elements) {
        rb_ary_push(arr, ULL2NUM(elem));
    }
    
    return arr;
}

VALUE TreeWrapper::rb_each(VALUE self) {
    VEBTree* tree = get_tree(self);
    
    if (!rb_block_given_p()) {
        return rb_enumeratorize(self, ID2SYM(rb_intern("each")), 0, nullptr);
    }
    
    std::vector<uint64_t> elements = tree->to_vector();
    for (uint64_t elem : elements) {
        rb_yield(ULL2NUM(elem));
    }
    
    return self;
}

void TreeWrapper::define_class(VALUE module) {
    VALUE cTree = rb_define_class_under(module, "Tree", rb_cObject);
    
    rb_define_alloc_func(cTree, rb_alloc);
    rb_define_method(cTree, "initialize", RUBY_METHOD_FUNC(rb_initialize), 1);
    rb_define_method(cTree, "insert", RUBY_METHOD_FUNC(rb_insert), 1);
    rb_define_method(cTree, "delete", RUBY_METHOD_FUNC(rb_delete), 1);
    rb_define_method(cTree, "include?", RUBY_METHOD_FUNC(rb_include), 1);
    rb_define_alias(cTree, "member?", "include?");
    rb_define_method(cTree, "size", RUBY_METHOD_FUNC(rb_size), 0);
    rb_define_method(cTree, "universe_size", RUBY_METHOD_FUNC(rb_universe_size), 0);
    rb_define_method(cTree, "min", RUBY_METHOD_FUNC(rb_min), 0);
    rb_define_method(cTree, "max", RUBY_METHOD_FUNC(rb_max), 0);
    rb_define_method(cTree, "successor", RUBY_METHOD_FUNC(rb_successor), 1);
    rb_define_method(cTree, "predecessor", RUBY_METHOD_FUNC(rb_predecessor), 1);
    rb_define_method(cTree, "empty?", RUBY_METHOD_FUNC(rb_empty), 0);
    rb_define_method(cTree, "clear", RUBY_METHOD_FUNC(rb_clear), 0);
    rb_define_method(cTree, "to_a", RUBY_METHOD_FUNC(rb_to_a), 0);
    rb_define_method(cTree, "each", RUBY_METHOD_FUNC(rb_each), 0);
    
    // Include Enumerable
    rb_include_module(cTree, rb_mEnumerable);
}

} // namespace VebTree

extern "C" void Init_veb_tree() {
    VALUE mVebTree = rb_define_module("VebTree");
    VebTree::TreeWrapper::define_class(mVebTree);
}
