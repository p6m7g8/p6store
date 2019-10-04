# This works like MixIns in Ruby

p6_return_obj_ref() {
    local obj="$1"

    p6__return "$obj"
}

p6_return_item_ref() {
    local item="$1"

    p6__return "$item"
}
