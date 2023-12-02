#!/usr/bin/env fish
sed 's/[a-z]//g' input > characters-removed
grep -o '^\d' characters-removed > twos-digit
grep -o '\d$' characters-removed > ones-digit
set -x twos_sum $(jq -s 'reduce .[] as $n (0; . + $n)' twos-digit)
set -x ones_sum $(jq -s 'reduce .[] as $n (0; . + $n)' ones-digit)
math "$twos_sum * 10 + $ones_sum"
