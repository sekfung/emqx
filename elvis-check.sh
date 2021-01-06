#!/bin/bash

set -euo pipefail

ELVIS_VERSION='1.0.0-emqx-1'

base=${GITHUB_BASE_REF:-$1}
elvis_version="${2:-$ELVIS_VERSION}"

echo "elvis -v: $elvis_version"
echo "git diff base: $base"

if [ ! -f ./elvis ] || [ "$(./elvis -v | grep -oE '[1-9]+\.[0-9]+\.[0-9]+\-emqx-[0-9]+')" != "$elvis_version" ]; then
    curl  -fLO "https://github.com/emqx/elvis/releases/download/$elvis_version/elvis"
    chmod +x ./elvis
fi

git fetch origin "$base"

git_diff() {
    git diff --name-only origin/"$base"...HEAD
}

bad_file_count=0
for n in $(git_diff); do
    if ! ./elvis rock "$n"; then
        bad_file_count=$(( bad_file_count + 1))
    fi
done
if [ $bad_file_count -gt 0 ]; then
    echo "elvis: $bad_file_count errors"
    exit 1
fi
