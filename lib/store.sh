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

    p6_file_create "$file"
    p6_file_write "$file" "$new"

    p6_return "$val"
}

##############################################################################
p6_store_hash_get() {
    local store="$1"
    local name="$2"
    local key="$3"

    if ! p6_string_blank "$key"; then
	local disk_dir=$(p6_store__disk "$store" "$name")

	local key_hash=$(p6_token_hash "$key")
	local pair_dir="$disk_dir/$key_hash"

	local val=$(p6_file_display "$pair_dir/value")
	p6_return "$val"
    fi
}

p6_store_hash_set() {
    local store="$1"
    local name="$2"
    local key="$3"
    local val="$4"

    if ! p6_string_blank "$key"; then
	local key_hash=$(p6_token_hash "$key")
	local disk_dir=$(p6_store__disk "$store" "$name")
	local pair_dir="$disk_dir/$key_hash"

	p6_dir_mk "$pair_dir"
	p6_file_create "$pair_dir/key"
	p6_file_write "$pair_dir/key" "$key"

	local old=$(p6_file_display "$pair_dir/value")
	p6_file_create "$pair_dir/value"
	p6_file_write "$pair_dir/value" "$val"
	p6_return "$old"
    fi
}

p6_store_hash_delete() {
    local store="$1"
    local name="$2"
    local key="$3"

    local key_hash=$(p6_token_hash "$key")

    local disk_dir=$(p6_store__disk "$store" "$name")
    local pair_dir="$disk_dir/$key_hash"

    local old_val=$(p6_file_display "$pair_dir/value")

    p6_dir_rmrf "$pair_dir"

    p6_return "$old_val"
}

##############################################################################
p6_store_list__i() {
    local disk_dir="$1"
    local next="$2"

    # current i
    local i_file="$disk_dir/i"
    if [ -n "$next" ]; then
	p6_file_write "$i_file" "$next"
    else
	local i_val=-1
	if ! p6_file_exists "$i_file"; then
	    p6_file_create "$i_file"
	    i_val=0
	else
	    i_val=$(p6_file_display "$i_file")
	fi

	p6_return "$i_val"
    fi
}

p6_store_list_get() {
    local store="$1"
    local name="$2"
    local i="$3"

    if ! p6_string_blank "$i"; then
	local disk_dir=$(p6_store__disk "$store" "$name")
	local item_dir="$disk_dir/$i"

	p6_file_display "$item_dir/data"
    fi
}

p6_store_list_add() {
    local store="$1"
    local name="$2"
    local new="$3"

    local disk_dir=$(p6_store__disk "$store" "$name")

    # current i
    local i_val=$(p6_store_list__i "$disk_dir")

    # make item dir
    local item_dir="$disk_dir/$i_val"
    p6_dir_mk "$item_dir"

    # save data
    p6_file_create "$item_dir/data"
    if ! p6_string_blank "$new"; then
	p6_file_write "$item_dir/data" "$new"
    fi

    # increment
    local next=$(p6_math_inc "$i_val")
    p6_store_list__i "$disk_dir" "$next"

    p6_return "$i_val"
}

p6_store_list_item_delete() {
    local store="$1"
    local name="$2"
    local old="$3"

    local disk_dir=$(p6_store__disk "$store" "$name")

    # current i
    local i_val=$(p6_store_list__i "$disk_dir")

    local j=0
    while [ $j -lt $i_val ]; do
	local item_dir="$disk_dir/$j"

	local data=$(p6_file_display "$item_dir/data")
	if [ x"$old" = x"$data" ]; then

	    local junk=$(p6_store_list_delete "$store" "$name" "$j")
	    p6_return "$j"
	    break
	fi
	j=$(p6_math_inc "$j")
    done
}

p6_store_list_delete() {
    local store="$1"
    local name="$2"
    local i="$3"

    if ! p6_string_blank "$i"; then
	local disk_dir=$(p6_store__disk "$store" "$name")
	local item_dir="$disk_dir/$i"
	local old=$(p6_file_display "$item_dir/data")
	p6_dir_rmrf "$item_dir"

	p6_return "$old"
    fi
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
