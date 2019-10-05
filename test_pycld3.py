import unittest

import cld3


class TestDetect(unittest.TestCase):
    def test_get_language(self):
        self.assertIsNone(cld3.get_language(""))
        self.assertIsNone(cld3.get_language(None))
        self.assertEqual(
            cld3.get_language("影響包含對氣候的變化以及自然資源的枯竭程度").language,  # noqa
            "zh",
        )
        self.assertEqual(
            cld3.get_language("This is a test").language,
            "en",
        )

    def test_get_frequent_languages(self):
        self.assertFalse(cld3.get_frequent_languages("", 1))
        self.assertFalse(cld3.get_frequent_languages(None, 1))

        # This is an especially important case where we want to make sure
        # that "und" is not included in the results;
        # see bottom of https://github.com/google/cld3/issues/15.
        langs = cld3.get_frequent_languages(
            "This piece of text is in English. Този текст е на Български.",
            num_langs=3,
        )
        self.assertEqual(len(langs), 2)
        self.assertEqual(
            sorted(i.language for i in langs),
            ["bg", "en"],
        )


if __name__ == "__main__":
    unittest.main()
