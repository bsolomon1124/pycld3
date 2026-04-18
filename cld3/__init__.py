import warnings

__version__ = '0.23'

warnings.warn(
    "pycld3 is archived and no longer maintained as of 2026. "
    "This is the final release. It does not build on Python 3.10+ without patches, "
    "and upstream CLD3 is effectively abandoned. "
    "Migrate to `gcld3` (Google's official bindings), `lingua-language-detector`, "
    "or `fasttext` with the lid.176 model. "
    "See https://github.com/bsolomon1124/pycld3 for details.",
    DeprecationWarning,
    stacklevel=2,
)

from ._cld3 import *  # noqa
