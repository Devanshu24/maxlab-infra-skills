from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALL = ROOT / "bin/install.sh"


def run(command: list[str], *, env=None):
    return subprocess.run(
        [str(value) for value in command],
        check=False,
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
    )


class InstallTests(unittest.TestCase):
    def test_installer_refuses_to_replace_an_existing_skill_link(self):
        with tempfile.TemporaryDirectory() as raw:
            home = Path(raw)
            destination = home / ".agents/skills/babel"
            destination.parent.mkdir(parents=True)
            destination.symlink_to("/tmp/someone-elses-babel-skill")
            env = os.environ.copy()
            env["HOME"] = str(home)
            result = run([INSTALL], env=env)
            self.assertEqual(result.returncode, 0)
            self.assertEqual(os.readlink(destination), "/tmp/someone-elses-babel-skill")
            self.assertIn("refusing to replace", result.stdout)


if __name__ == "__main__":
    unittest.main()
