"""Offline packaging and Claude reminder integration checks."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class PackageTests(unittest.TestCase):
    def test_only_supported_guides_are_shipped(self):
        self.assertEqual({p.name for p in (ROOT / "skills/lang-tutor/languages").glob("*.md")}, {"_common.md", "english.md", "japanese.md"})

    def test_both_hosts_resolve_the_same_skills(self):
        for host in (".codex-plugin", ".claude-plugin"):
            manifest = json.loads((ROOT / host / "plugin.json").read_text())
            skills = ROOT / manifest["skills"]
            self.assertEqual({p.parent.name for p in skills.glob("*/SKILL.md")}, {"lang-tutor", "lang-tutor-review", "lang-tutor-review-test"})

    def test_reminder_is_quiet_until_activation_and_reads_shared_prefs(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            (home / ".lang-tutor").mkdir()
            (home / ".lang-tutor/prefs.md").write_text("Target language: Japanese\nNative language: Traditional Chinese (zh-TW)\n")
            transcript = home / "session.jsonl"
            env = dict(os.environ, HOME=tmp, CLAUDE_PLUGIN_ROOT=str(ROOT))
            command = json.loads((ROOT / "hooks/hooks.json").read_text())["hooks"]["UserPromptSubmit"][0]["hooks"][0]["command"]
            def run(payload):
                return subprocess.run(command, shell=True, input=json.dumps(payload), text=True, capture_output=True, env=env, check=True).stdout
            self.assertEqual(run({}), "")
            transcript.write_text("ordinary session")
            self.assertEqual(run({"transcript_path": str(transcript)}), "")
            transcript.write_text("# Language Tutor Mode")
            output = run({"transcript_path": str(transcript)})
            self.assertIn("Japanese", output)
            self.assertIn("Traditional Chinese", output)

if __name__ == "__main__":
    unittest.main()
