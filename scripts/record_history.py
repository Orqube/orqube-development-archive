#!/usr/bin/env python3
"""Generate a factual daily index of commits already present in this repository."""
import datetime as dt
import json
import pathlib
import subprocess
from collections import defaultdict
from zoneinfo import ZoneInfo

# Translate display titles without rewriting immutable historical Git commits.
ENGLISH_SUBJECTS = {
    "c9c772aee3a030430838455aed55ce788a499aeb": "docs: document mathematical validation and state-transition rules for independent chain v0.5",
    "a4c9f3fed529ac400d6668dfa8baa69eb415861f": "docs: add links to the independent-chain mathematical specification and verification record"
}

def git(*args):
    return subprocess.check_output(["git", *args]).decode("utf-8", errors="replace")

def generate():
    days = defaultdict(list)
    for sha in git("rev-list", "--reverse", "HEAD").splitlines():
        subject = git("show", "-s", "--format=%s", sha).strip()
        if subject.startswith("chore: update automatic worklog"):
            continue
        timestamp = git("show", "-s", "--format=%cI", sha).strip()
        date = dt.datetime.fromisoformat(timestamp).astimezone(ZoneInfo("Asia/Seoul")).date().isoformat()
        paths = git("diff-tree", "--root", "--no-commit-id", "--name-only", "-r", "-z", sha).split("\0")
        paths = [p for p in paths if p and not p.startswith("worklogs/automatic/")]
        if not paths:
            continue
        entry = {"commit": sha, "subject": ENGLISH_SUBJECTS.get(sha, subject), "committed_at": timestamp, "files": paths}
        if sha in ENGLISH_SUBJECTS:
            entry["subject_is_translation"] = True
        days[date].append(entry)
    root = pathlib.Path("worklogs/automatic")
    root.mkdir(parents=True, exist_ok=True)
    for date, entries in sorted(days.items()):
        (root / (date + ".json")).write_text(json.dumps(entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        lines = ["# Development record — " + date, "", "Commit dates use Asia/Seoul. This index records repository changes; it does not certify tests or deployments. Selected historical titles are displayed in English translation; original Git commits remain unchanged.", ""]
        for item in entries:
            # JSON string quoting prevents commit titles from injecting Markdown blocks.
            title = json.dumps(item["subject"], ensure_ascii=False)
            lines += ["## " + item["commit"][:12], "", "Commit title: " + title.replace("<", "&lt;").replace(">", "&gt;"), "", "Changed files: " + str(len(item["files"])) + ". Full paths are in the accompanying JSON file.", ""]
        (root / (date + ".md")).write_text("\n".join(lines), encoding="utf-8")
    links = ["# Automatic development records", "", "Generated from commits in this repository. Dates: Asia/Seoul.", ""]
    links += ["- [" + day + "](" + day + ".md) · [file list](" + day + ".json)" for day in sorted(days, reverse=True)]
    (root / "README.md").write_text("\n".join(links) + "\n", encoding="utf-8")

if __name__ == "__main__":
    generate()
