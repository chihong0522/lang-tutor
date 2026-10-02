"""Offline packaging and cross-host reminder hook integration checks."""
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
        manifests = {}
        for host in (".codex-plugin", ".claude-plugin"):
            manifest = json.loads((ROOT / host / "plugin.json").read_text())
            manifests[host] = manifest
            skills = ROOT / manifest["skills"]
            self.assertEqual({p.parent.name for p in skills.glob("*/SKILL.md")}, {"lang-tutor", "lang-tutor-review", "lang-tutor-review-test"})
        self.assertEqual(manifests[".codex-plugin"]["version"], manifests[".claude-plugin"]["version"])
        self.assertEqual(manifests[".codex-plugin"]["hooks"], "./hooks/hooks.json")

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

    def test_codex_reminder_is_session_scoped_and_cleared_at_session_end(self):
        with tempfile.TemporaryDirectory() as tmp:
            plugin_data = Path(tmp) / "plugin-data"
            env = dict(os.environ, PLUGIN_ROOT=str(ROOT), PLUGIN_DATA=str(plugin_data))
            hooks = json.loads((ROOT / "hooks/hooks.json").read_text())["hooks"]

            def run(event, session_id, prompt=""):
                command = hooks[event][0]["hooks"][0]["command"]
                payload = {
                    "hook_event_name": event,
                    "session_id": session_id,
                    "prompt": prompt,
                }
                return subprocess.run(
                    command,
                    shell=True,
                    input=json.dumps(payload),
                    text=True,
                    capture_output=True,
                    env=env,
                    check=True,
                ).stdout

            self.assertEqual(run("UserPromptSubmit", "thread-a", "ordinary request"), "")
            activated = run("UserPromptSubmit", "thread-a", "$lang-tutor English beginner")
            self.assertIn("lang-tutor mode is active", activated)
            self.assertIn("lang-tutor mode is active", run("UserPromptSubmit", "thread-a", "Help me with this task"))
            self.assertEqual(run("UserPromptSubmit", "thread-b", "Help me with this task"), "")
            qualified = run(
                "UserPromptSubmit",
                "thread-c",
                "[$lang-tutor:lang-tutor](/plugin/skills/lang-tutor/SKILL.md)",
            )
            self.assertIn("lang-tutor mode is active", qualified)
            self.assertEqual(run("SessionEnd", "thread-a"), "")
            self.assertEqual(run("UserPromptSubmit", "thread-a", "Help me again"), "")

if __name__ == "__main__":
    unittest.main()
