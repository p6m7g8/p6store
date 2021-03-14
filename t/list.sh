#!/bin/sh

main() {

	. ../p6test/lib/_bootstrap.sh
	p6_p6test_bootstrap "../p6test"

	. lib/store.sh

	p6_test_setup "55"

	p6_test_start "p6_store_list_create"
	(
		local s=$(p6_store_create "s")

		p6_test_run "p6_store_list_create"
		p6_test_assert_run_ok "no args"

		p6_test_run "p6_store_list_create" "$s"
		p6_test_assert_run_ok "store only"

		p6_store_list_create "$s" "list_name"
		p6_test_assert_run_ok "store, list_name"

		p6_store_destroy "$s"
		p6_test_assert_dir_not_exists "$s/list_name" "$s/list_name: cleaned up"
	)
	p6_test_finish

	p6_test_start "p6_store_list_add"
	(
		local s=$(p6_store_create "s")
		p6_store_list_create "$s" "list_name"

		p6_test_run "p6_store_list_add" "$s" "list_name"
		p6_test_assert_blank "$(p6_test_run_stderr)" "store, list_name: no stderr"
		p6_test_assert_eq "$(p6_test_run_stdout)" "0" "item # 0 returned"
		p6_test_assert_dir_exists "$s/list_name/0" "$s/list_name/0: item dir made"
		local item=$(p6_store_list_get "$s" "list_name" "0")
		p6_test_assert_blank "$item" "correctly blank / dne"

		p6_test_run "p6_store_list_add" "$s" "list_name" "k"
		p6_test_assert_blank "$(p6_test_run_stderr)" "store, list_name, k: no stderr"
		p6_test_assert_eq "$(p6_test_run_stdout)" "1" "item # 1 returned"
		p6_test_assert_dir_exists "$s/list_name/1" "$s/list_name/1: item dir made"
		item=$(p6_store_list_get "$s" "list_name" "1")
		p6_test_assert_eq "$item" "k" "item # 1 retreived as k"

		p6_store_destroy "$s"
		p6_test_assert_dir_not_exists "$s/list_name" "$s/list_name: cleaned up"
	)
	p6_test_finish

	p6_test_start "p6_store_list_get"
	(
		local s=$(p6_store_create "s")
		p6_store_list_create "$s" "list_name"
		local junk=$(p6_store_list_add "$s" "list_name" "k")

		p6_test_run "p6_store_list_get" "$s" "list_name"
		p6_test_assert_run_ok "store, list_name"

		p6_test_run "p6_store_list_get" "$s" "list_name" "-1"
		p6_test_assert_run_ok "store, list_name, -1"

		p6_test_run "p6_store_list_get" "$s" "list_name" "5"
		p6_test_assert_run_ok "store, list_name, 5"

		p6_test_run "p6_store_list_get" "$s" "list_name" "0"
		p6_test_assert_blank "$(p6_test_run_stderr)" "store, list_name, 0: no stderr"
		p6_test_assert_eq "$(p6_test_run_stdout)" "k" "got item # 0 as k"

		p6_store_destroy "$s"
		p6_test_assert_dir_not_exists "$s/list_name" "$s/list_name: cleaned up"
	)
	p6_test_finish

	p6_test_start "p6_store_list_delete"
	(
		local s=$(p6_store_create "s")
		p6_store_list_create "$s" "list_name"
		local junk=$(p6_store_list_add "$s" "list_name" "k")

		p6_test_run "p6_store_list_delete" "$s" "list_name"
		p6_test_assert_run_ok "store, list_name"

		p6_test_run "p6_store_list_delete" "$s" "list_name" "-1"
		p6_test_assert_run_ok "store, list_name, -1"

		p6_test_run "p6_store_list_delete" "$s" "list_name" "5"
		p6_test_assert_run_ok "store, list_name, 5"

		p6_test_run "p6_store_list_delete" "$s" "list_name" "0"
		p6_test_assert_blank "$(p6_test_run_stderr)" "store, list_name, 0: no stderr"
		p6_test_assert_eq "$(p6_test_run_stdout)" "k" "old item # 0 returned as k"

		p6_store_destroy "$s"
		p6_test_assert_dir_not_exists "$s/list_name" "$s/list_name: cleaned up"
	)
	p6_test_finish

	p6_test_start "p6_store_list_item_delete"
	(
		local s=$(p6_store_create "s")
		p6_store_list_create "$s" "list_name"

		local i=4
		while [ $i -gt 0 ]; do
			local junk=$(p6_store_list_add "$s" "list_name" "$i")
			i=$(p6_math_dec "$i")
		done

		p6_test_run "p6_store_list_item_delete" "$s" "list_name"
		p6_test_assert_run_ok "store, list_name"

		p6_test_run "p6_store_list_item_delete" "$s" "list_name" "-1"
		p6_test_assert_run_ok "store, list_name, -1"

		p6_test_run "p6_store_list_item_delete" "$s" "list_name" "64"
		p6_test_assert_run_ok "store, list_name, 3"

		p6_test_run "p6_store_list_item_delete" "$s" "list_name" "1"
		p6_test_assert_blank "$(p6_test_run_stderr)" "store, list_name, 1: no stderr"
		p6_test_assert_eq "$(p6_test_run_stdout)" "3" "position of 1 is 3 (4 3 2 1) [zero based]"

		p6_store_destroy "$s"
		p6_test_assert_dir_not_exists "$s/list_name" "$s/list_name: cleaned up"
	)
	p6_test_finish

	p6_test_teardown
}

main "$@"
