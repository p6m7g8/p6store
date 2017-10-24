#!/bin/sh -vx

main() {

    pwd
    env
    uname -a
    whoami
    find ../../p6m7g8 -type f

    . ../p6test/lib/_colors.sh
    . ../p6test/lib/_util.sh
    . ../p6test/lib/backends/tap.sh
    . ../p6test/lib/asserts/aserts.sh
    . ../p6test/lib/harness.sh
    . ../p6test/lib/api.sh

    p6_test_harness_tests_run "t"
}

main "$@"
