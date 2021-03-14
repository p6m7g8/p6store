#!/bin/sh

main() {

    . ../p6test/lib/_bootstrap.sh
    p6_p6test_bootstrap "../p6test"

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
