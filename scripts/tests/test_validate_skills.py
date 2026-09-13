import importlib.util
from pathlib import Path
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('validate_skills', SCRIPTS / 'validate-skills.py')
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)
VALIDATOR = SCRIPTS.parent / 'skills/.system/skill-creator/scripts/quick_validate.py'


class CatalogChecks(unittest.TestCase):
    def make_skill(self, root, body='', frontmatter=None):
        skill = root / '.system/example-skill'
        skill.mkdir(parents=True)
        metadata = frontmatter or 'name: example-skill\ndescription: Read and update example documents.'
        (skill / 'SKILL.md').write_text(f'---\n{metadata}\n---\n\n# Example\n\n{body}', encoding='utf-8')
        return skill

    def test_links_ignore_fenced_examples_but_check_real_anchors(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            skill = self.make_skill(root, '[Details](references/details.md#usage)\n\n````markdown\n[Example](missing.md)\n```python\npass\n```\n````\n')
            (skill / 'references').mkdir()
            details = skill / 'references/details.md'
            details.write_text('# Details\n\n## Usage\n', encoding='utf-8')
            self.assertEqual(checks.audit(root, VALIDATOR)['errors'], [])
            details.write_text('# Details\n', encoding='utf-8')
            errors = checks.audit(root, VALIDATOR)['errors']
            self.assertEqual(len(errors), 1)
            self.assertIn('missing anchor', errors[0])

    def test_ui_metadata_errors_are_actionable(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            skill = self.make_skill(root)
            (skill / 'agents').mkdir()
            (skill / 'agents/openai.yaml').write_text('interface:\n  short_description: "Too short"\n  default_prompt: "Do the task"\npolicy:\n  allow_implicit_invocation: false\n', encoding='utf-8')
            errors = checks.audit(root, VALIDATOR)['errors']
            self.assertEqual(len(errors), 2)
            self.assertTrue(any('short_description' in e for e in errors))
            self.assertTrue(any('$example-skill' in e for e in errors))

    def test_latest_validator_rejects_unfinished_scaffold(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.make_skill(root, '[TODO: Add real instructions.]\n')
            errors = checks.audit(root, VALIDATOR)['errors']
            self.assertEqual(len(errors), 1)
            self.assertIn('unfinished TODO', errors[0])

    def test_empty_catalog_is_not_a_successful_audit(self):
        with tempfile.TemporaryDirectory() as temp:
            result = checks.audit(Path(temp), VALIDATOR)
            self.assertEqual(result['skill_count'], 0)
            self.assertEqual(result['errors'], ['No skills found under the specified root'])


if __name__ == '__main__':
    unittest.main()
