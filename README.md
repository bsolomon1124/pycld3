# `pycld3`

Python bindings to the Compact Language Detector v3 (CLD3).

This package contains Python bindings (via Cython) to Google's [CLD3](https://github.com/google/cld3/) library.

To build this extension, you will need:

- [Cython](https://cython.readthedocs.io/en/latest/)
- [Protobuf](https://github.com/protocolbuffers/protobuf), including the `protoc` Protobuf compiler available as an executable

Building the extension does *not* require the Chromium repository.

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
LanguagePrediction(language='und', probability=0.0, is_reliable=False, proportion=0.0)
```

## FAQ

### `cld3` incorrectly detects my input, how can I fix this?

In some cases, you cannot.  Language detection algorithms in general may perform poorly with very short inputs.
Rarely should you trust the output of something like `detect("hi")`.  Keep this limitation in mind regardless
of what library you are using.

### How do I fix an error telling me "The Protobuf compiler, `protoc`, could not be found"?

The Protobuf compiler, `protoc`, is required for installing this package.

Below are some quick install commands, but please consult [the official protobuf repository](https://github.com/protocolbuffers/protobuf) for information on installing Protobuf.

_Ubuntu Linux_:

```console
$ sudo apt-get update
$ sudo apt-get install protobuf-compiler
```

_Mac OSX_:

```console
$ brew update && brew install protobuf
```

### Authors

This repository contains a fork of [`google/cld3`](https://github.com/google/cld3/) at commit 06f695f.  The license for `google/cld3` can be found at
[LICENSES/CLD3\_LICENSE](https://github.com/bsolomon1124/pycld3/blob/master/LICENSES/CLD3_LICENSE).

This repository is a combination of changes introduced by various [forks](https://github.com/google/cld3/network/members) of `google/cld3` by the following people:

- Johannes Baiter ([@jbaiter](https://github.com/jbaiter))
- Elizabeth Myers ([@Elizafox](https://github.com/Elizafox))
- Witold Bołt ([@houp](https://github.com/houp))
- Alfredo Luque ([@iamthebot](https://github.com/iamthebot))
- WISESIGHT ([@ThothMedia](https://github.com/ThothMedia))
- RNogales ([@RNogales94](https://github.com/RNogales94))
- Brad Solomon ([@bsolomon1124](https://github.com/bsolomon1124))
