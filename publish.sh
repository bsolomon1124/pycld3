#!/usr/bin/env bash
set -e
set -x
ver=$(python setup.py --version)
python3 setup.py bdist_wheel
twine upload dist/pycld3-${ver}.tar.gz
twine upload dist/pycld3-${ver}*.whl
