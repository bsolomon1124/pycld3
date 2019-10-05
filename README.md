# `pycld3`

Python bindings to the Compact Language Detector v3 (CLD3).

This package contains Python bindings (via Cython) to Google's [CLD3](https://github.com/google/cld3/) library.

## Installation

Install via [Pip](https://pypi.org/project/pycld3/):

```bash
python -m pip install pycld3
```

Developers: see also [Building from Source](#for-developers-building-from-source).

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

### How do I fix an error telling me "The Protobuf compiler, `protoc`, could not be found"?

The Protobuf compiler, `protoc`, is required for building this package.  (However, if you are installing from PyPI with `pip`, then the
`.h` and `.cc` files generated with `protoc` will already be included.)

Below are some quick install commands, but please consult [the official protobuf repository](https://github.com/protocolbuffers/protobuf) for information on installing Protobuf.

_Ubuntu Linux_:

```bash
sudo apt-get update
sudo apt-get install protobuf-compiler
```

_Mac OSX_:

```bash
brew update && brew install protobuf
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

## For Developers: Building from Source

To build this extension from scratch, you will need:

- [Cython](https://cython.readthedocs.io/en/latest/)
- [Protobuf](https://github.com/protocolbuffers/protobuf), including the `protoc` Protobuf compiler available as an executable

Building the extension does *not* require the Chromium repository.

With these installed, you can run the following from the project root:

```bash
python setup.py bdist_wheel
python setup.py build_ext --inplace
```

Testing:

```bash
make test
```
