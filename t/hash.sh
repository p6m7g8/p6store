#!/bin/sh

main() {

    . ../p6test/lib/_bootstrap.sh
    p6_p6test_bootstrap "../p6test"

    . lib/store.sh

    p6_test_setup "43"

    p6_test_start "p6_store_hash_create"
    (
	local s=$(p6_store_create "s")

	p6_test_run "p6_store_hash_create"
	p6_test_assert_run_ok "no args"

	p6_test_run "p6_store_hash_create" "$s"
	p6_test_assert_run_ok "store only"

	p6_store_hash_create "$s" "hash_name"
	p6_test_assert_run_ok "store, hash_name"

	p6_store_destroy "$s"
	p6_test_assert_dir_not_exists "$s/hash_name" "$s/hash_name: cleaned up"
    )
    p6_test_finish

    p6_test_start "p6_store_hash_set"
    (
	local s=$(p6_store_create "s")
	p6_store_hash_create "$s" "hash_name"

	p6_test_run "p6_store_hash_set" "$s" "hash_name"
	p6_test_assert_run_ok "store, hash_name"

	local k1=k

	p6_test_run "p6_store_hash_set" "$s" "hash_name" "$k1"
	p6_test_assert_run_ok "store, hash_name, $k1"

	local key_hash=$(p6_token_hash "$k1")
	p6_test_assert_dir_exists "$s/hash_name/$key_hash" "pair dir created: $s/hash_name/$key_hash"

	local key=$(p6_file_display "$s/hash_name/$key_hash/key")
	p6_test_assert_eq "$k1" "$key" "key($key) retreived as $k1"

	local val=$(p6_file_display "$s/hash_name/$key_hash/value")
	p6_test_assert_blank "$val" "no value"

	local k2=j

	p6_test_run "p6_store_hash_set" "$s" "hash_name" "$k2" "v"
	p6_test_assert_run_ok "store, hash_name, $k2->v"

	key_hash=$(p6_token_hash "$k2")
	p6_test_assert_dir_exists "$s/hash_name/$key_hash" "pair dir created: $s/hash_name/$key_hash"

	key=$(p6_file_display "$s/hash_name/$key_hash/key")
	p6_test_assert_eq "$k2" "$key" "key retreived as $k2"

	val=$(p6_file_display "$s/hash_name/$key_hash/value")
	p6_test_assert_eq "$val" "v" "value of $k2 is v"

	p6_test_run "p6_store_hash_set" "$s" "hash_name" "$k2" "N"
	p6_test_assert_blank "$(p6_test_run_stderr)" "s hash_name $k2 N:_name no stderr"
	p6_test_assert_eq "$(p6_test_run_stdout)" "v" "old val returned"

	p6_store_destroy "$s"
	p6_test_assert_dir_not_exists "$s/hash_name" "$s/hash_name: cleaned up"
    )
    p6_test_finish

    p6_test_start "p6_store_hash_get"
    (
	local s=$(p6_store_create "s")
	p6_store_hash_create "$s" "hash_name"

	local junk=$(p6_store_hash_set "$s" "hash_name" "k" "v")

	p6_test_run "p6_store_hash_get" "$s" "hash_name"
	p6_test_assert_run_ok "store, hash_name"

	p6_test_run "p6_store_hash_get" "$s" "hash_name" "k"
	p6_test_assert_blank "$(p6_test_run_stderr)" "s hash_name $k2 N:_name no stderr"
	p6_test_assert_eq "$(p6_test_run_stdout)" "v" "value of k is v"
    )
    p6_test_finish

    p6_test_start "p6_store_hash_delete"
    (
	local s=$(p6_store_create "s")
	p6_store_hash_create "$s" "hash_name"

	p6_test_run "p6_store_hash_delete" "$s" "hash_name"
	p6_test_assert_run_ok "store, hash_name"

	p6_test_run "p6_store_hash_delete" "$s" "hash_name" "k"
	p6_test_assert_run_ok "store, hash_name, k"

	local k1=k
	local key_hash=$(p6_token_hash "$k1")
	p6_test_assert_dir_not_exists "$s/hash_name/$key_hash" "pair dir DNE: $s/hash_name/$key_hash"

	local k2=j
	local junk=$(p6_store_hash_set "$s" "hash_name" "$k2" "v")
	p6_test_run "p6_store_hash_delete" "$s" "hash_name" "$k2"
	p6_test_assert_blank "$(p6_test_run_stderr)" "s hash_name $k2 N:_name no stderr"
	p6_test_assert_eq "$(p6_test_run_stdout)" "v" "old value of $k2 is v"

	p6_store_destroy "$s"
	p6_test_assert_dir_not_exists "$s/hash_name" "$s/hash_name: cleaned up"
    )
    p6_test_finish

    p6_test_teardown
}

main "$@"
