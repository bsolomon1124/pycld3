#!/usr/bin/env bash

# This script builds MacOS SDK 10.15 wheels using pyenv
# That's because GitHub Actions uses the 10.13 SDK.
# Longer-term goal is to wrap all the CI into one
# (Azure DevOps may be the best choice there.)

set -e  # no pipefail

brew upgrade protobuf || brew install protobuf

for v in '3.5.9' '3.6.10' '3.7.7' '3.8.2'; do
  export PYENV_VERSION="$v"
  make clean
  rm -rf wheels
  rm -rf venv
  python3 -m venv ./venv
  . ./venv/bin/activate
  python3 -V
  python3 -m pip install -q --upgrade --disable-pip-version-check -r requirements-dev.txt
  python3 -m pip install -q --upgrade --disable-pip-version-check delocate
  python3 -m pip wheel --disable-pip-version-check --no-deps --wheel-dir wheels/ .
  delocate-wheel -w wheelhouse -v ./wheels/*.whl
  deactivate
  unset PYENV_VERSION
done

make clean
rm -rf venv
echo "...DONE"
ls wheelhouse

