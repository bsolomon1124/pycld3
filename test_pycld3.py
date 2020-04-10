#!/usr/bin/env python
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

        res = cld3.get_language("وفي وقت سابق اليوم السبت قالت الرئاسة المصرية -في بيان- إنها تتطلع لقيام الولايات المتحدة بدور فعال، خاصة في ضوء وصول المفاوضات بين الدول الثلاث لطريق مسدود.")  # noqa
        self.assertEqual(res.language, "ar")

        res = cld3.get_language("مغلوں کی خام اور سفید و سیاہ میں تصویر کشی دراصل مودی کی دائیں بازو والی بی جے پی حکومت کے اقتدار میں بھارتی مسلمانوں سے روا رکھے جانے سلوک کو درست ٹھہرانے کی کوشش کے سوا کچھ نہیں۔ ")  # noqa
        self.assertEqual(res.language, "ur")

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

        langs = cld3.get_frequent_languages(
            "Derrière ce sujet des retraites, il y a beaucoup de questions autour de ce que sera le travail de demain. Nous ne sommes pas au bout de ce chantier. Jusqu’à présent nous avons ajusté, il est temps de refonder. On le fera en transparence, et tous ensemble.",  # noqa
            num_langs=5,
        )
        self.assertEqual(len(langs), 1)
        self.assertEqual(langs[0].language, "fr")


if __name__ == "__main__":
    unittest.main()
