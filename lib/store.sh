######################################################################
#<
#
# Function:
#     $store = p6_store_create(name, max_objs)
#
# Arg(s):
#    name - name of store
#    max_objs - max objects
#
# Return(s):
#    $store - reference to object store
#
#>
#/ Synopsis:
#/   Creates a temporal object store
#/
#/ Notes:
#/   Depends on p6_transients
######################################################################
p6_store_create() {
    local name="$1"     # name of store
    local max_objs="$2" # max objects

    local store=$(p6_transient_create "$name" "$max_objs")

    p6_return "$store" # reference to object store
}

######################################################################
#<
#
# Function:
#     void = p6_store_destroy(store)
#
# Arg(s):
#    store - ref to store to delete
#
# Return(s):
#    void - none
#
#>
#/ Notes:
#/   Depends on p6_transients
######################################################################
p6_store_destroy() {
    local store="$1" # ref to store to delete

    p6_transient_delete "$store"

    p6_return_void
}

######################################################################
#<
#
# Function:
#     $ref = p6_store_ref(store)
#
# Arg(s):
#    store - store to find ref of
#
# Return(s):
#    $ref - ref to store
#
#>
######################################################################
p6_store_ref() {
    local store="$1" # store to find ref of

    local ref=$(p6_store__ref "$store")

    p6_return "$ref" # ref to store
}

######################################################################
#<
#
# Function:
#     $copy = p6_store_copy(store)
#
# Arg(s):
#    store - store to copy
#
# Return(s):
#    $copy - copied store
#
#>
######################################################################
p6_store_copy() {
    local store="$1" # store to copy

    local copy=$(p6_store__copy "$store")

    p6_return "$copy" # copied store
}

######################################################################
#<
#
# Function:
#     void = p6_store_scalar_create(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the scalar
#
# Return(s):
#    void - none
#
#>
######################################################################
p6_store_scalar_create() {
    local store="$1" # the store
    local name="$2"  # the name of the scalar

    p6_store__init_structure "$store" "$name"

    p6_return_void
}

######################################################################
#<
#
# Function:
#     void = p6_store_list_create(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#
# Return(s):
#    void - none
#
#>
######################################################################
p6_store_list_create() {
    local store="$1" # the store
    local name="$2"  # the name of the list

    p6_store__init_structure "$store" "$name"

    p6_return_void
}

######################################################################
#<
#
# Function:
#     void = p6_store_hash_create(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the hash
#
# Return(s):
#    void - none
#
#>
######################################################################
p6_store_hash_create() {
    local store="$1" # the store
    local name="$2"  # the name of the hash

    p6_store__init_structure "$store" "$name"

    p6_return_void
}

######################################################################
#<
#
# Function:
#     $val = p6_store_scalar_get(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the scalar
#
# Return(s):
#    $val - value of the scalar
#
#>
######################################################################
p6_store_scalar_get() {
    local store="$1" # the store
    local name="$2"  # the name of the scalar

    local disk_dir=$(p6_store__disk "$store" "$name")
    local val=$(p6_file_display "$disk_dir/data")

    p6_return "$val" # value of the scalar
}

######################################################################
#<
#
# Function:
#     $val = p6_store_scalar_set(store, name, new)
#
# Arg(s):
#    store - the store
#    name - the name of the scalar
#    new - set scalar value to this
#
# Return(s):
#    $val - the value
#
#>
######################################################################
p6_store_scalar_set() {
    local store="$1" # the store
    local name="$2"  # the name of the scalar
    local new="$3"   # set scalar value to this

    local disk_dir=$(p6_store__disk "$store" "$name")
    local file="$disk_dir/data"

    local val=$(p6_file_display "$file")

    p6_file_create "$file"
    p6_file_write "$file" "$new"

    p6_return "$val" # the value
}

######################################################################
#<
#
# Function:
#     $val = p6_store_hash_get(store, name, key)
#
# Arg(s):
#    store - the store
#    name - the name of the hash
#    key - the key to get the value of
#
# Return(s):
#    $val - the value of the key
#    void - none
#
#>
######################################################################
p6_store_hash_get() {
    local store="$1" # the store
    local name="$2"  # the name of the hash
    local key="$3"   # the key to get the value of

    if ! p6_string_blank "$key"; then
	local disk_dir=$(p6_store__disk "$store" "$name")

	local key_hash=$(p6_token_hash "$key")
	local pair_dir="$disk_dir/$key_hash"

	local val=$(p6_file_display "$pair_dir/value")
	p6_return "$val" # the value of the key
    else
	p6_return_void
    fi
}

######################################################################
#<
#
# Function:
#     $old = p6_store_hash_set(store, name, key, val)
#
# Arg(s):
#    store - the store
#    name - the name of the hash
#    key - the key who's value to set
#    val - value to set
#
# Return(s):
#    $old - the previous value of key
#    void - none
#
#>
######################################################################
p6_store_hash_set() {
    local store="$1" # the store
    local name="$2"  # the name of the hash
    local key="$3"   # the key who's value to set
    local val="$4"   # value to set

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
	p6_return "$old" # the previous value of key
    else
	p6_return_void
    fi
}

######################################################################
#<
#
# Function:
#     $old_val = p6_store_hash_delete(store, name, key)
#
# Arg(s):
#    store - the store
#    name - the name of the hash
#    key - the key to delete
#
# Return(s):
#    $old_val - previou key value
#
#>
######################################################################
p6_store_hash_delete() {
    local store="$1" # the store
    local name="$2"  # the name of the hash
    local key="$3"   # the key to delete

    local key_hash=$(p6_token_hash "$key")

    local disk_dir=$(p6_store__disk "$store" "$name")
    local pair_dir="$disk_dir/$key_hash"

    local old_val=$(p6_file_display "$pair_dir/value")

    p6_dir_rmrf "$pair_dir"

    p6_return "$old_val" # previou key value
}

######################################################################
#<
#
# Function:
#     $item = p6_store_list_get(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#
# Return(s):
#    $item - the item
#
#>
######################################################################
p6_store_list_get() {
    local store="$1" # the store
    local name="$2"  # the name of the list
    local i="$3"     # index of list item to return

    if ! p6_string_blank "$i"; then
	local disk_dir=$(p6_store__disk "$store" "$name")
	local item_dir="$disk_dir/$i"

	local item=$(p6_file_display "$item_dir/data")

	p6_return "$item" # the item
    fi
}

######################################################################
#<
#
# Function:
#     $i_val = p6_store_list_add(store, name, new)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#    new - new item to add
#
# Return(s):
#    $i_val - value of added item
#
#>
######################################################################
p6_store_list_add() {
    local store="$1" # the store
    local name="$2"  # the name of the list
    local new="$3"   # new item to add

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

    p6_return "$i_val" # value of added item
}

######################################################################
#<
#
# Function:
#     $j = p6_store_list_item_delete(store, name, old)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#    old - value to delete [1st one]
#
# Return(s):
#    $j - indec of deleted item
#    void - none
#
#>
######################################################################
p6_store_list_item_delete() {
    local store="$1" # the store
    local name="$2"  # the name of the list
    local old="$3"   # value to delete [1st one]

    local disk_dir=$(p6_store__disk "$store" "$name")

    # current i
    local i_val=$(p6_store_list__i "$disk_dir")

    local j=0
    while [ $j -lt $i_val ]; do
	local item_dir="$disk_dir/$j"

	local data=$(p6_file_display "$item_dir/data")
	if [ x"$old" = x"$data" ]; then

	    local junk=$(p6_store_list_delete "$store" "$name" "$j")
	    p6_return "$j" # indec of deleted item
	    break
	fi
	j=$(p6_math_inc "$j")
    done

    p6_return_void
}

######################################################################
#<
#
# Function:
#     $old = p6_store_list_delete(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#
# Return(s):
#    $old - old item
#    void - none
#
#>
######################################################################
p6_store_list_delete() {
    local store="$1" # the store
    local name="$2"  # the name of the list
    local i="$3"     # index of item to delete

    if ! p6_string_blank "$i"; then
	local disk_dir=$(p6_store__disk "$store" "$name")
	local item_dir="$disk_dir/$i"
	local old=$(p6_file_display "$item_dir/data")
	p6_dir_rmrf "$item_dir"

	p6_return "$old" # old item
    else
	p6_return_void
    fi
}

######################################################################
#<
#
# Function:
#     void = p6_store__init_structure(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#
# Return(s):
#    void - none
#
#>
######################################################################
p6_store__init_structure() {
    local store="$1" # the store
    local name="$2"  # the name of the list

    local disk_dir=$(p6_store__disk "$store" "$name")
    p6_dir_mk "$disk_dir"

    p6_return_void
}

######################################################################
#<
#
# Function:
#     $dir = p6_store__disk(store, name)
#
# Arg(s):
#    store - the store
#    name - the name of the list
#
# Return(s):
#    $dir - the on disk location as a path
#
#>
######################################################################
p6_store__disk() {
    local store="$1" # the store
    local name="$2"  # the name of the list

    local dir="$store/$name"

    p6_return "$dir" # the on disk location as a path
}

######################################################################
#<
#
# Function:
#     $next = p6_store_list__i(disk_dir, next)
#
# Arg(s):
#    disk_dir - path to on disk location
#    next - optional next value
#
# Return(s):
#    $next - new i value
#    $i_val - i's value
#
#>
######################################################################
p6_store_list__i() {
    local disk_dir="$1" # path to on disk location
    local next="${2:-}" # optional next value

    # current i
    local i_file="$disk_dir/i"
    if [ -n "$next" ]; then
	p6_file_write "$i_file" "$next"
	p6_return "$next" # new i value
    else
	local i_val=-1
	if ! p6_file_exists "$i_file"; then
	    p6_file_create "$i_file"
	    i_val=0
	else
	    i_val=$(p6_file_display "$i_file")
	fi

	p6_return "$i_val" # i's value
    fi
}