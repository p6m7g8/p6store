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

    p6_test_setup "7"

    p6_test_start "p6_store_create"
    (
	p6_test_run "p6_store_create"
	p6_test_assert_run_ok "no args"

	p6_test_run "p6_store_create" "s"
	p6_test_assert_blank "$(p6_test_run_stderr)" "s: no stderr"
	p6_test_assert_contains "/tmp/p6/transients/s" "$(p6_test_run_stdout)" "s: prefix"
	p6_test_assert_dir_exists "$(p6_test_run_stdout)" "s: exists -> $(p6_test_run_stdout)"

	p6_store_destroy "$(p6_test_run_stdout)"
	p6_test_assert_dir_not_exists "$(p6_test_run_stdout)" "s: cleaned up"
    )
    p6_test_finish

    p6_test_teardown
}

main "$@"
