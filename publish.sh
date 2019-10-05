#!/usr/bin/env bash
set -e
rm -rf dist/
python setup.py sdist --formats=gztar,zip bdist_wheel
twine upload dist/pycld3-*
