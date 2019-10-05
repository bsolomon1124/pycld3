#!/usr/bin/env bash
set -e
rm -rf dist/
python3 setup.py bdist_wheel
twine upload dist/pycld3-*
