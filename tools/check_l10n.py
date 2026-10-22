"""Check that every string the UI asks for actually has a Chinese translation.

A missing key is not a crash: L10n falls back to English. That makes it a silent
bug, which is why it needs a script instead of an eyeball. Both sides are
compared in Swift source form, so the escaped \\n in a two-line sentence matches
on both sides without any unescaping.
"""
import re
import sys
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent / "ThirdRow.swiftpm"
LITERAL = re.compile(r'l10n\.t\("((?:[^"\\]|\\.)*)"\)')
KEY = re.compile(r'^\s*"((?:[^"\\]|\\.)*)":\s*"', re.MULTILINE)


def main():
    l10n_src = (ROOT / "Core" / "Models" / "L10n.swift").read_text(encoding="utf-8")
    table_start = l10n_src.index("static let table")
    keys = set(KEY.findall(l10n_src[table_start:]))

    used = set()
    per_file = {}
    for path in sorted(ROOT.rglob("*.swift")):
        if path.name == "L10n.swift":
            continue
        hits = LITERAL.findall(path.read_text(encoding="utf-8"))
        if hits:
            per_file[path.name] = hits
            used.update(hits)

    missing = sorted(used - keys)
    unused = sorted(keys - used)

    print(f"translated keys : {len(keys)}")
    print(f"strings used    : {len(used)}")
    print(f"files wired     : {len(per_file)}")

    if missing:
        print("\nMISSING (would stay English):")
        for m in missing:
            where = [f for f, hits in per_file.items() if m in hits]
            print(f"  {m!r}  in {', '.join(where)}")

    if unused:
        print("\nUNUSED keys (dead translation):")
        for u in unused:
            print(f"  {u!r}")

    # Any user-facing literal still not routed through l10n.
    raw = []
    for path in sorted(ROOT.rglob("*.swift")):
        if path.name == "L10n.swift":
            continue
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            s = line.strip()
            if s.startswith("//") or s.startswith("///"):
                continue
            if re.search(r'Text\("[A-Za-z]', line):
                raw.append(f"  {path.name}:{i}  {s}")

    if raw:
        print("\nHARDCODED Text(\"...\") still in English:")
        for r in raw:
            print(r)

    ok = not missing and not raw
    print("\n" + ("OK" if ok else "NEEDS FIX"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
