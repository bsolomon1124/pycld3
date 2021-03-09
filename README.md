# `pycld3`

Python bindings to the Compact Language Detector v3 (CLD3).

[![CircleCI](https://circleci.com/gh/bsolomon1124/pycld3.svg?style=svg)](https://circleci.com/gh/bsolomon1124/pycld3)
[![License](https://img.shields.io/github/license/bsolomon1124/pycld3.svg)](https://github.com/bsolomon1124/pycld3/blob/master/LICENSE)
[![PyPI](https://img.shields.io/pypi/v/pycld3.svg)](https://pypi.org/project/pycld3/)
[![Wheel](https://img.shields.io/pypi/wheel/pycld3)](https://img.shields.io/pypi/wheel/pycld3)
[![Status](https://img.shields.io/pypi/status/pycld3.svg)](https://pypi.org/project/pycld3/)
[![Python](https://img.shields.io/pypi/pyversions/pycld3.svg)](https://pypi.org/project/pycld3)
[![Implementation](https://img.shields.io/pypi/implementation/pycld3)](https://pypi.org/project/pycld3)

## Newer Alternative: `gcld3`

**Note**: Since the original publication of this `pycld3`, Google's `cld3` authors have published the Python package [gcld3](https://pypi.org/project/gcld3/), which are official Python bindings built with [pybind](https://github.com/pybind/pybind11). Please check that project out as it is part of the canonical `cld3` repository and will likely stay in better lock step with any `cld3` changes over time.

## Overview

This package contains Python bindings (via Cython) to Google's [CLD3](https://github.com/google/cld3/) library.

```python
>>> import cld3
>>> cld3.get_language("影響包含對氣候的變化以及自然資源的枯竭程度")
LanguagePrediction(language='zh', probability=0.999969482421875, is_reliable=True, proportion=1.0)
```

The library outputs BCP-47-style language codes. For some languages, output is differentiated by script. Language and script names from Unicode CLDR. It supports over 100 languages/scripts. See full list of [supported languages/scripts](https://github.com/google/cld3/blob/master/README.md#supported-languages) in Google's CLD3 documentation.

## Installing with Wheels: Supported Versions and Platforms

This project supports **CPython versions 3.6 through 3.9.**

We publish [wheels](https://pypi.org/project/pycld3/#files) for the following matrix:

- **MacOS**: CPython 3.6 thru 3.9
- **Linux**: CPython 3.6 thru 3.9; ([manylinux1](https://www.python.org/dev/peps/pep-0513/#the-manylinux1-policy))

<sup>The wheels for both MacOS and manylinux1 include the external protobuf library copied into the wheel itself
via [auditwheel](https://github.com/pypa/auditwheel) or
[delocate](https://github.com/matthew-brett/delocate) so that you won't need to install any extra non-PyPI dependencies.</sup>

If you are installing on one of the variants listed above, you should **not** need to have `protoc` or `libprotobuf` installed:

```bash
python -m pip install -U pycld3
```

## Installing from Source: Prerequisites

If you are not on a platform variant that is eligible to use a wheel, you may still be able to use `pycld3` via its [source distribution](https://docs.python.org/3/distutils/sourcedist.html) (`tar.gz`), but a bit more work is required to install.
Namely, you'll also need:

- the Protobuf compiler (the `protoc` executable)
- the Protobuf development headers and `libprotoc` library
- a compiler, preferably `g++`

Please consult [the official protobuf repository](https://github.com/protocolbuffers/protobuf) for information on installing Protobuf.
The project contains an [Installation README](https://github.com/protocolbuffers/protobuf/tree/master/src) that covers installation
on Windows and Unix.

If for whatever reason you are on a Unix host but unable to use the wheels (for instance, if you have an i686 architecture), here is a quick-and-dirty guide to installing.

### Debian/Ubuntu

```bash
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    g++ \
    protobuf-compiler \
    libprotobuf-dev
python -m pip install -U pycld3
```

### Alpine Linux

_Note_:
[Alpine Linux does not support PyPI wheels](https://pythonspeed.com/articles/alpine-docker-python/)
as of April 2020.  The steps below are mandatory on Alpine Linux because you will need
to install from the source distribution.  If the situation permits, using a Debian distro
should be much easier (and faster).

```bash
apk --update add g++ protobuf protobuf-dev
python -m pip install -U pycld3
```

### CentOS/RHEL

Install from source, as root/UID 0:

```bash
sudo su -
set -ex
pushd /opt
PROTOBUF_VERSION='3.11.4'
yum update -y
yum install -y autoconf automake gcc-c++ glibc-headers gzip libtool make python3-devel zlib-devel
curl -Lo /opt/protobuf.tar.gz \
    "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
tar -xzvf protobuf.tar.gz
rm -f protobuf.tar.gz
pushd "protobuf-${PROTOBUF_VERSION}"
./configure --with-zlib --disable-debug && make && make install && ldconfig --verbose
popd && rm -rf "protobuf-${PROTOBUF_VERSION}" && popd && set +ex

python -m pip install -U pycld3
```

Note: the steps above are for CentOS 8.  For earlier versions, you may need to replace:

- `gcc-c++` with `g++`
- `python3-devel` with `python-devel`

### MacOS/Homebrew

```bash
brew update
brew upgrade protobuf || brew install -v protobuf
python -m pip install -U pycld3
```

### Windows

Please consult Protobuf's
[C++ Installation - Windows](https://github.com/protocolbuffers/protobuf/tree/master/src#c-installation---windows)
section for help with installing Protobuf on Windows.

If you would like to help contribute Windows wheels (preferably as a job within the project's
CI/CD pipelines), please [file an issue](https://github.com/bsolomon1124/pycld3).

## Usage

`cld3` exports two module-level functions, `get_language()` and `get_frequent_languages()`:

```python
>>> import cld3

>>> cld3.get_language("影響包含對氣候的變化以及自然資源的枯竭程度")
LanguagePrediction(language='zh', probability=0.999969482421875, is_reliable=True, proportion=1.0)

>>> cld3.get_language("This is a test")
LanguagePrediction(language='en', probability=0.9999980926513672, is_reliable=True, proportion=1.0)

>>> for lang in cld3.get_frequent_languages(
...     "This piece of text is in English. Този текст е на Български.",
...     num_langs=3
... ):
...     print(lang)
...
LanguagePrediction(language='bg', probability=0.9173890948295593, is_reliable=True, proportion=0.5853658318519592)
LanguagePrediction(language='en', probability=0.9999790191650391, is_reliable=True, proportion=0.4146341383457184)
```

## FAQ

### `cld3` incorrectly detects my input.  How can I fix this?

A first resort is to **preprocess (clean) your input text** based on conditions specific to your program.

A salient example is to remove URLs and email addresses from the input.  **CLD3 (unlike [CLD2](https://github.com/CLD2Owners/cld2))
does almost none of this cleaning for you**, in the spirit of not penalizing other users with overhead that they may not need.

Here's such an example using a simplified URL regex from _Regular Expressions Cookbook, 2nd ed._:

```python
>>> import re
>>> import cld3

# cld3 does not ignore the URL components by default
>>> s = "Je veux que: https://site.english.com/this/is/a/url/path/component#fragment"
>>> cld3.get_language(s)
LanguagePrediction(language='en', probability=0.5319557189941406, is_reliable=False, proportion=1.0)

>>> url_re = r"\b(?:https?://|www\.)[a-z0-9-]+(\.[a-z0-9-]+)+(?:[/?].*)?"
>>> new_s = re.sub(url_re, "", s)
>>> new_s
'Je veux que: '
>>> cld3.get_language(new_s)
LanguagePrediction(language='fr', probability=0.9799421429634094, is_reliable=True, proportion=1.0)
```

<sup>_Note_: This URL regex aims for simplicity.  It requires a domain name, and doesn't allow a username or password; it allows the scheme
(http or https) to be omitted if it can be inferred from the subdomain (www).  Source: _Regular Expressions Cookbook, 2nd ed._ - Goyvaerts & Levithan.</sup>

**In some other cases, you cannot fix the incorrect detection.**
Language detection algorithms in general may perform poorly with very short inputs.
Rarely should you trust the output of something like `detect("hi")`.  Keep this limitation in mind regardless
of what library you are using.

Please remember that, at the end of the day, this project is just a Python wrapper to the CLD3 C++ library that does the actual heavy-lifting.

### I'm seeing an error during `pip` installation.  How can I fix this?

First, please make sure you have read the [installation](#installation-supported-versions-and-platforms) section that that you have
installed Protobuf if necessary.

If that doesn't help, please [file an issue](https://github.com/bsolomon1124/pycld3/issues) in this repository.
The build process for this project is somewhat complex because it involves both Cython and Protobuf, but I do my best
to make it work everywhere possible.

### Protobuf is installed, but I'm still seeing "cannot open shared object file"

If you've installed Protobuf, but are seeing an error such as:

```
ImportError: libprotobuf.so.22: cannot open shared object file: No such file or directory
```

This likely means that Python is not finding the `libprotobuf` shared object,
possibly because `ldconfig` didn't do what it was supposed to.
You may need to tell it where to look.

You can find where the library sits via:

```bash
$ find /usr -name 'libprotoc.so' \( -type l -o -type f \)
/usr/local/lib/libprotoc.so
```

Then, you can add the directory containing this file to `LD_LIBRARY_PATH`:

```bash
export LD_LIBRARY_PATH="$(dirname $(find /usr -name 'libprotoc.so' \( -type l -o -type f \))):$LD_LIBRARY_PATH"
```

You can quickly test that this worked:

```bash
$ python -c 'import cld3; print(cld3.get_language("影響包含對氣候的變化以及自然資源的枯竭程度"))'
LanguagePrediction(language='zh', probability=0.999969482421875, is_reliable=True, proportion=1.0)
```

### Authors

This repository contains a fork of [`google/cld3`](https://github.com/google/cld3/) at commit 06f695f.  The license for `google/cld3` can be found at
[LICENSES/CLD3\_LICENSE](https://github.com/bsolomon1124/pycld3/blob/master/LICENSES/CLD3_LICENSE).

This repository is a combination of changes [introduced](https://github.com/google/cld3/issues/15) by [various forks](https://github.com/google/cld3/network/members) of `google/cld3` by the following people:

- Johannes Baiter ([@jbaiter](https://github.com/jbaiter))
- Elizabeth Myers ([@Elizafox](https://github.com/Elizafox))
- Witold Bołt ([@houp](https://github.com/houp))
- Alfredo Luque ([@iamthebot](https://github.com/iamthebot))
- WISESIGHT ([@wisesight](https://github.com/wisesight))
- RNogales ([@RNogales94](https://github.com/RNogales94))
- Brad Solomon ([@bsolomon1124](https://github.com/bsolomon1124))
