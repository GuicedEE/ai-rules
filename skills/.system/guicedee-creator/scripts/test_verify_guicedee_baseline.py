"""Regression checks for Jackson 3 JPMS opens, including retained Jackson annotations."""
from pathlib import Path
import tempfile
import unittest

from verify_guicedee_baseline import check_module_open_rules


class JacksonOpens(unittest.TestCase):
    def check(self, source, target):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            main = root / 'src/main/java'
            tests = root / 'src/test/java'
            main.mkdir(parents=True)
            tests.mkdir(parents=True)
            (main / 'Dto.java').write_text('package example.dto;\n' + source, encoding='utf-8')
            (main / 'module-info.java').write_text(f'module example {{ opens example.dto to {target}; }}', encoding='utf-8')
            (tests / 'module-info.java').write_text('module example.test { requires org.junit.jupiter.api; }', encoding='utf-8')
            return check_module_open_rules(root, main / 'module-info.java', tests / 'module-info.java', set())

    def test_jackson3_import_accepts_jackson3_target(self):
        ok, detail = self.check('import tools.jackson.databind.ObjectMapper;\nclass Dto {}', 'tools.jackson.databind')
        self.assertTrue(ok, detail)

    def test_retained_annotations_require_jackson3_target(self):
        source = 'import com.fasterxml.jackson.annotation.JsonProperty;\nclass Dto { @JsonProperty String name; }'
        ok, detail = self.check(source, 'tools.jackson.databind')
        self.assertTrue(ok, detail)
        ok, detail = self.check(source, 'com.fasterxml.jackson.databind')
        self.assertFalse(ok, detail)
        self.assertIn('example.dto -> tools.jackson.databind', detail)


if __name__ == '__main__':
    unittest.main()
