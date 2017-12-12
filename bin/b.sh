#!/bin/sh -xv

main() {
    . ../p6test/lib/_colors.sh
    . ../p6test/lib/_util.sh
    . ../p6test/lib/backends/tap.sh
    . ../p6test/lib/asserts/aserts.sh
    . ../p6test/lib/harness.sh
    . ../p6test/lib/api.sh
    . ../p6test/lib/bench.sh

    p6_test_bench "100" "t/store.sh"
}

main "$@"
