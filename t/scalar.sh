#!/bin/sh

main() {

    . ../p6test/lib/_colors.sh
    . ../p6test/lib/_util.sh
    . ../p6test/lib/backends/tap.sh
    . ../p6test/lib/asserts/aserts.sh
    . ../p6test/lib/harness.sh
    . ../p6test/lib/api.sh

    . ../p6common/lib/const.sh
    . ../p6common/lib/io.sh
    . ../p6common/lib/tokens.sh
    . ../p6common/lib/dir.sh
    . ../p6common/lib/file.sh
    . ../p6common/lib/string.sh
    . ../p6common/lib/transients.sh

    . lib/store.sh

    p6_test_setup "22"

    p6_test_start "p6_store_scalar_create"
    (
	local s=$(p6_store_create "s")
	p6_test_run "p6_store_scalar_create"
	p6_test_assert_run_ok "no args"

	p6_test_run "p6_store_scalar_create" "$s"
	p6_test_assert_run_ok "store only"

	p6_test_run "p6_store_scalar_create" "$s" "scalar_name"
	p6_test_assert_run_ok "store, scalar_scalar_name"
	p6_test_assert_dir_exists "$s/scalar_name" "scalar scalar_named/inited: $s/scalar_name"

	p6_store_destroy "$s"
	p6_test_assert_dir_not_exists "$s/scalar_name" "$s/scalar_name: cleaned up"
    )
    p6_test_finish

    p6_test_start "p6_store_scalar_set"
    (
	local s=$(p6_store_create "s")
	p6_store_scalar_create "$s" "scalar_name"
	p6_test_run "p6_store_scalar_set" "$s" "scalar_name" "philip"
	p6_test_assert_run_ok "scalar<-philip"

	local val=$(p6_store_scalar_get "$s" "scalar_name")
	p6_test_assert_eq "philip" "$val" "val retreived"

	p6_test_run "p6_store_scalar_set" "$s" "scalar_name" "gollucci"
	p6_test_assert_blank "$(p6_test_run_stderr)" "s scalar_name no stderr"
	p6_test_assert_contains "philip" "$(p6_test_run_stdout)" "previous val returned when set"

	val=$(p6_store_scalar_get "$s" "scalar_name")
	p6_test_assert_eq "gollucci" "$val" "new val retreived"

	p6_store_destroy "$s"
	p6_test_assert_dir_not_exists "$s/scalar_name" "$s/scalar_name: cleaned up"
    )
    p6_test_finish

    p6_test_start "p6_store_scalar_get"
    (
	local s=$(p6_store_create "s")
	p6_store_scalar_create "$s" "scalar_name"
	local junk=$(p6_store_scalar_set "$s" "scalar_name" "matthew")

	p6_test_run "p6_store_scalar_get" "$s" "scalar_name"
	p6_test_assert_blank "$(p6_test_run_stderr)" "s scalar_name: no stderr"
	p6_test_assert_contains "matthew" "$(p6_test_run_stdout)" "val retreived"

	p6_store_destroy "$s"
	p6_test_assert_dir_not_exists "$s/scalar_name" "$s/scalar_name: cleaned up"
    )
    p6_test_teardown
}

main "$@"
