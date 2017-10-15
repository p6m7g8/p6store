##############################################################################
p6_store_create() {
    local name="$1"
    local max_objs="$2"

    local store=$(p6_transient_create "$name" "$max_objs")

    p6_return "$store"
}

p6_store_destroy() {
    local store="$1"

    p6_transient_delete "$store"
}

p6_store_ref() {
    local store="$1"

    local ref=$(p6_store__ref "$store")

    p6_return "$ref"
}

p6_store_copy() {
    local store="$1"

    local copy=$(p6_store__copy "$store")

    p6_return "$copy"
}

##############################################################################
p6_store_scalar_create() {
    local store="$1"
    local name="$2"

    p6_store__init_structure "$store" "$name"
}

p6_store_list_create() {
    local store="$1"
    local name="$2"

    p6_store__init_structure "$store" "$name"
}

p6_store_hash_create() {
    local store="$1"
    local name="$2"

    p6_store__init_structure "$store" "$name"
}

##############################################################################
p6_store_scalar_get() {
    local store="$1"
    local name="$2"

    local disk_dir=$(p6_store__disk "$store" "$name")
    local val=$(p6_file_display "$disk_dir/data")

    p6_return "$val"
}

p6_store_scalar_set() {
    local store="$1"
    local name="$2"
    local new="$3"

    local disk_dir=$(p6_store__disk "$store" "$name")
    local file="$disk_dir/data"

    local val=$(p6_file_display "$file")

    p6_file_write "$file" "$new"

    p6_return "$val"
}

##############################################################################
p6_store_hash_set() {
    local store="$1"
    local name="$2"
    local key="$3"
    local val="$4"

    local key_hash=$(p6_hash "$key")

    local disk_dir=$(p6_store__disk "$store" "$name")
    local pair_dir="$disk_dir/$key_hash"

    p6_dir_mk "$pair_dir"
    p6_file_write "$pair_dir/key" "$key"
    p6_file_write "$pair_dir/value" "$val"
}

p6_store_hash_delete() {
    local store="$1"
    local name="$2"
    local key="$3"

    local key_hash=$(p6_hash "$key")

    local disk_dir=$(p6_store__disk "$store" "$name")
    local pair_dir="$disk_dir/$key_hash"

    local old_val=$(p6_file_display "$pair_dir/value")

    p6_dir_rmrf "$pair_dir"

    p6_return "$old_val"
}

##############################################################################
p6_store_list_add() {
    local store="$1"
    local name="$2"
    local new="$3"

    local rand=$(p6_mkpasswd "4")

    local disk_dir=$(p6_store__disk "$store" "$name")
    local item_dir="$disk_dir/$rand"

    p6_dir_mk "$item_dir"
    p6_file_create "$item_dir/data"
    p6_file_write "$item_dir/data" "$val"
}

p6_store_list_delete() {
    local store="$1"
    local name="$2"

    local new="$3"

    p6_return
}

##############################################################################
p6_store__init_structure() {
    local store="$1"
    local name="$2"

    local disk_dir=$(p6_store__disk "$store" "$name")
    p6_dir_mk "$disk_dir"
}

p6_store__disk() {
    local store="$1"
    local name="$2"

    local dir="$store/$name"

    p6_return "$dir"
}
