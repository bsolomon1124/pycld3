#!/usr/bin/env bash

set -ex

for PYBIN in /opt/python/*/bin; do
    case "$PYBIN" in 
      *'27'*)
        ;;
      *)
        # Py3 only
        echo "Building wheel for $PYBIN"
        "${PYBIN}/pip" install -U -r /io/requirements-dev.txt
        "${PYBIN}/pip" wheel /io/ -w wheelhouse/
        ;;
    esac
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    echo "Vendoring in external shared libs for $whl"
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

for PYBIN in /opt/python/*/bin/; do
    case "$PYBIN" in 
      *'27'*)
        ;;
      *)
        echo "Installing for $PYBIN"
        "${PYBIN}/pip" install pycld3 --no-index -f /io/wheelhouse
    esac
done
