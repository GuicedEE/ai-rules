"""Regression checks for Jackson 3 opens and lifecycle SPI registration."""
from pathlib import Path
import tempfile
import unittest

from verify_guicedee_baseline import (
    check_module_open_rules, check_lifecycle_spi_registrations, check_bootstrap_main,
)


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


class Bootstrap(unittest.TestCase):
    def check(self, startup):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            main = root / 'src/main/java'
            main.mkdir(parents=True)
            (main / 'App.java').write_text('''package example;
class App {
    public static void main(String[] args) {
        LogUtils.addHighlightedConsoleLogger(Level.INFO);
        IGuiceContext.registerModule("example");
        ''' + startup + '\n    }\n}', encoding='utf-8')
            return check_bootstrap_main(root, 'example')

    def test_accepts_existing_direct_injection(self):
        ok, detail = self.check('IGuiceContext.instance().inject();')
        self.assertTrue(ok, detail)

    def test_accepts_process_entry(self):
        ok, detail = self.check('GuiceApplication.run(() -> { });')
        self.assertTrue(ok, detail)

    def test_requires_startup(self):
        ok, detail = self.check('')
        self.assertFalse(ok, detail)
        self.assertIn('GuiceApplication.run', detail)


class LifecycleRegistration(unittest.TestCase):
    def check(self, declaration='', module_registered=True, classpath_registered=True):
        spi = 'com.guicedee.client.services.lifecycle.IGuicePreStartup'
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            main = root / 'src/main/java'
            main.mkdir(parents=True)
            (main / 'Startup.java').write_text(
                'package example;\nclass Startup implements IGuicePreStartup<Startup> {\n'
                + declaration + '\n}', encoding='utf-8')
            module = main / 'module-info.java'
            registration = f'provides {spi} with example.Startup;' if module_registered else ''
            module.write_text(f'module example {{ {registration} }}', encoding='utf-8')
            if classpath_registered:
                services = root / 'src/main/resources/META-INF/services'
                services.mkdir(parents=True)
                (services / spi).write_text('example.Startup\n', encoding='utf-8')
            return check_lifecycle_spi_registrations(root, module)

    def test_accepts_boxed_override(self):
        ok, detail = self.check('@Override public Integer sortOrder() { return 100; }')
        self.assertTrue(ok, detail)

    def test_accepts_inherited_default(self):
        ok, detail = self.check()
        self.assertTrue(ok, detail)

    def test_rejects_primitive_override(self):
        ok, detail = self.check('@Override public int sortOrder() { return 100; }')
        self.assertFalse(ok, detail)
        self.assertIn('Integer sortOrder()', detail)

    def test_requires_both_launch_modes(self):
        for module_registered, classpath_registered in [(False, True), (True, False)]:
            with self.subTest(module=module_registered, classpath=classpath_registered):
                ok, detail = self.check(module_registered=module_registered,
                                        classpath_registered=classpath_registered)
                self.assertFalse(ok, detail)
                self.assertIn('provides' if not module_registered else 'META-INF/services', detail)


if __name__ == '__main__':
    unittest.main()
