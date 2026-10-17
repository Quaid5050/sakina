#!/usr/bin/env python3
"""Fails when a translation ARB file is missing a key, has an extra key, or
drops a placeholder that the English template uses (SPEC §5.4, PLAN M0.6).

Usage: python3 tool/check_arb_keys.py [lib/l10n]
"""
import json
import pathlib
import re
import sys

ARB_DIR = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else 'lib/l10n')
TEMPLATE = ARB_DIR / 'app_en.arb'
PLACEHOLDER = re.compile(r'\{(\w+)')


def messages(path):
    data = json.loads(path.read_text(encoding='utf-8'))
    return {k: v for k, v in data.items() if not k.startswith('@')}


def placeholders(text):
    # Top-level ICU arguments only, e.g. "{count, plural, ...}" -> count.
    return set(PLACEHOLDER.findall(text))


def main():
    template = messages(TEMPLATE)
    failed = False
    for path in sorted(ARB_DIR.glob('app_*.arb')):
        if path == TEMPLATE:
            continue
        other = messages(path)
        for key in sorted(set(template) - set(other)):
            print(f'::error file={path}::missing key "{key}"')
            failed = True
        for key in sorted(set(other) - set(template)):
            print(f'::error file={path}::extra key "{key}" (not in app_en.arb)')
            failed = True
        for key in sorted(set(template) & set(other)):
            missing = placeholders(template[key]) - placeholders(other[key])
            if missing:
                names = ', '.join(sorted(missing))
                print(f'::error file={path}::"{key}" drops placeholder(s) {names}')
                failed = True
        if not failed:
            print(f'ok  {path} ({len(other)} keys)')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
