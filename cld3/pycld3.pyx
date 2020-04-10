# cython: language_level=3
from collections import namedtuple

from libcpp.string cimport string
from libcpp.vector cimport vector

# N.B.:
# Several functions here involve the comparison
#
#     if res.language != ident.kUnknown
#
# As it stands above, this will raise
#
#     Invalid types for '!=' (string, const char [])
#
# because those are the CPP types of those two values, respectively.
# (From the Python space, both will show as <class 'bytes'>, and
# the value of ident.kUnknown is b'und'.  Therefore, we cast both
# to bytes:
# https://cython.readthedocs.io/en/latest/src/tutorial/strings.html#passing-byte-strings
#
# What will *not* work are either of these:
#
#     str(res.language) != ident.kUnknown
#     res.language.decode("utf-8") != ident.kUnknown


cdef extern from "nnet_language_identifier.h" namespace "chrome_lang_id::NNetLanguageIdentifier":
    cdef struct Result:
        string language
        float probability
        bint is_reliable
        float proportion


cdef extern from "nnet_language_identifier.h" namespace "chrome_lang_id":
    cdef cppclass NNetLanguageIdentifier:
        NNetLanguageIdentifier(int min_num_bytes, int max_num_bytes);
        Result FindLanguage(string &text)
        vector[Result] FindTopNMostFreqLangs(string &text, int num_langs)
        # const char NNetLanguageIdentifier::kUnknown[] = "und";
        # from cld3/src/nnet_language_identifier.cc
        const char kUnknown[]


LanguagePrediction = namedtuple(
    "LanguagePrediction",
    ("language", "probability", "is_reliable", "proportion")
)


cdef class LanguageIdentifier:
    """Python interface to cld3."""

    cdef NNetLanguageIdentifier* model
    cdef unsigned int min_bytes
    cdef unsigned int max_bytes

    def __init__(
        self,
        unsigned int min_bytes=0,
        unsigned int max_bytes=1024,
    ):
        """Initialize a LanguageIdentifier.

        :param min_bytes: The minimum number of bytes to consider.
        :type min_bytes: int
        :param max_bytes: The maximum number of bytes to consider.
        :type max_bytes: int
        """

        self.min_bytes = min_bytes
        self.max_bytes = max_bytes
        self.model = new NNetLanguageIdentifier(self.min_bytes, self.max_bytes)

    def get_language(self, unicode text):
        """Get the most likely language for the given text.

        The prediction is based on the first N bytes of `text`,
        where N is the minumum between the number of interchange-valid
        UTF8 bytes and `max_bytes`.

        If N is less than `min_bytes` long, then this function returns
        None.

        If the language cannot be determined, None will be returned.

        If the input is the empty string, None will be returned.

        :param text: Input text for which to detect language.
        :type text: str
        :return: :class:`LanguagePrediction` object, or None
        """

        if not text:
            return None

        cdef Result res = self.model.FindLanguage(text.encode('utf8'))

        if <bytes> res.language != <bytes> self.model.kUnknown:
            language = res.language.decode("utf8")
            return LanguagePrediction(
                language,
                res.probability,
                res.is_reliable,
                res.proportion
            )
        else:
            return None

    def get_frequent_languages(
        self,
        unicode text,
        int num_langs,
    ):
        """Find the most frequent languages in the given text.

        Splits the input text into spans based on the script, predicts
        a language for each span, and returns a list storing the top
        `num_langs` most frequent languages.

        The number of bytes considered for each span is the minimum between
        the size of th span and `self.max_bytes`.

        If more languages are requested than what is available in the input,
        then the list returned will only have the number of results
        found.

        If the size of the span is less than `self.min_bytes` long,
        then the span is skipped.

        If the input text is too long, only the first 1024 bytes
        are processed.

        :param text: Input text for which to detect language.
        :type text: str
        :param num_langs: The maximum number of languages included in result.
        :type num_langs: int
        :returns: List of most frequent languages detected.
        :rtype: list
        """

        if not text:
            return []

        cdef vector[Result] results = self.model.FindTopNMostFreqLangs(
            text.encode("utf8"),
            num_langs
        )
        out = []
        for res in results:
            if <bytes> res.language != <bytes> self.model.kUnknown:
                language = res.language.decode("utf8")
                out.append(
                    LanguagePrediction(
                        language,
                        res.probability,
                        res.is_reliable,
                        res.proportion
                    )
                )
        return out


def get_language(
    unicode text,
    unsigned int min_bytes=0,
    unsigned int max_bytes=1024,
):
    """Get the most likely language for the given text.

    The prediction is based on the first N bytes of `text`,
    where N is the minumum between the number of interchange-valid
    UTF8 bytes and `max_bytes`.

    If N is less than `min_bytes` long, then this function returns
    None.

    If the language cannot be determined, None will be returned.

    If the input is the empty string, None will be returned.

    :param text: Input text for which to detect language.
    :type text: str
    :return: :class:`LanguagePrediction` object, or None
    :param min_bytes: The minimum number of bytes to consider.
    :type min_bytes: int
    :param max_bytes: The maximum number of bytes to consider.
    :type max_bytes: int
    """

    if not text:
        return None

    cdef NNetLanguageIdentifier* ident = new NNetLanguageIdentifier(
        min_bytes, max_bytes
    )
    cdef Result res = ident.FindLanguage(text.encode("utf8"))
    try:
        if <bytes> res.language != <bytes> ident.kUnknown:
            language = res.language.decode("utf8")
            return LanguagePrediction(
                language,
                res.probability,
                res.is_reliable,
                res.proportion
            )
        else:
            return None
    finally:
        del ident


# N.B.: We cannot use
#     get_language.__doc__ = LanguageIdentifier.get_language.__doc__
# because __doc__ for builtin_function_or_method is readonly.


def get_frequent_languages(
    unicode text,
    unsigned int num_langs,
    unsigned int min_bytes=0,
    unsigned int max_bytes=1024,
):
    """Find the most frequent languages in the given text.

    Splits the input text into spans based on the script, predicts
    a language for each span, and returns a list storing the top
    `num_langs` most frequent languages.

    The number of bytes considered for each span is the minimum between
    the size of th span and `self.max_bytes`.

    If more languages are requested than what is available in the input,
    then the list returned will only have the number of results
    found.

    If the size of the span is less than `self.min_bytes` long,
    then the span is skipped.

    If the input text is too long, only the first 1024 bytes
    are processed.

    :param text: Input text for which to detect language.
    :type text: str
    :param num_langs: The maximum number of languages included in result.
    :type num_langs: int
    :param min_bytes: The minimum number of bytes to consider.
    :type min_bytes: int
    :param max_bytes: The maximum number of bytes to consider.
    :type max_bytes: int
    :returns: List of most frequent languages detected.
    :rtype: list
    """

    if not text:
        return []

    cdef NNetLanguageIdentifier* ident = new NNetLanguageIdentifier(
        min_bytes, max_bytes
    )
    cdef vector[Result] results = ident.FindTopNMostFreqLangs(
        text.encode("utf8"),
        num_langs
    )
    out = []
    for res in results:
        if <bytes> res.language != <bytes> ident.kUnknown:
            language = res.language.decode("utf8")
            out.append(
                LanguagePrediction(
                    language, res.probability, res.is_reliable, res.proportion
                )
            )
    del ident
    return out


# Clean up namespace
del namedtuple
