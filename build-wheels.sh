#!/usr/bin/env bash

# Does the heavy lifting of building manylinux1 wheels
# Hijacked mostly from https://github.com/pypa/python-manylinux-demo
#
# See also:
# - https://www.python.org/dev/peps/pep-0513/#the-manylinux1-policy
# - https://github.com/pypa/manylinux

set -ex

{
  cat /etc/redhat-release;
  ls -UC /opt/python/
  protoc --version
  pkg-config --cflags protobuf
  pkg-config --libs protobuf
} > /io/system_info.log

for PYBIN in /opt/python/*/bin; do
  case "$PYBIN" in 
    *'27'*)
      ;;
    *)
      # Py3 only
      echo "Building wheel for $PYBIN"
      "${PYBIN}/pip" install --disable-pip-version-check --upgrade -r /io/requirements-dev.txt
      "${PYBIN}/pip" wheel /io/ -w wheelhouse/
      ;;
  esac
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
  echo "Vendoring in external shared libs for $whl"
  auditwheel repair "$whl" --plat "$PLAT" -w /io/wheelhouse/
done

for PYBIN in /opt/python/*/bin/; do
  case "$PYBIN" in 
    *'27'*)
      ;;
    *)
      echo "Installing for $PYBIN"
      "${PYBIN}/pip" install pycld3 --disable-pip-version-check --no-index -f /io/wheelhouse
      "${PYBIN}/python" -m unittest discover -v -s /io/
  esac
done


