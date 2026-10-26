#!/usr/bin/env python3
"""Capture the Apple Watch screenshot for one watch simulator + locale.

Needs the paired simulators with both apps installed (docs/watch-testing.md).
The watch app is closed, a published state is injected (the names come from
lib/core/localization/app_strings_<locale>.dart, like the iPhone publishes
them) and the app is relaunched in that language.

usage: python3 tool/screenshots/capture_watch.py <watch-udid> <locale: en|es|de|fr|it>
Writes build/screenshots/shots/watch/<locale>/grid.png
"""
import os
import plistlib
import re
import subprocess
import sys
import tempfile
import time

UDID, LOCALE = sys.argv[1:3]
BUNDLE = 'com.artlab.moodcalendar.watchkitapp'
APPLE_LOCALE = {'en': 'en_US', 'es': 'es_ES', 'de': 'de_DE', 'fr': 'fr_FR', 'it': 'it_IT'}[LOCALE]
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, 'build', 'screenshots', 'shots', 'watch', LOCALE)
os.makedirs(OUT, exist_ok=True)

# Order the iPhone would publish for someone who uses calm the most.
MOODS = ['calm', 'happy', 'neutral', 'sad', 'angry', 'brave']
TODAY = 'calm'


def sh(*args):
    return subprocess.run(args, capture_output=True, text=True).stdout


def mood_names():
    source = open(os.path.join(REPO, 'lib', 'core', 'localization', f'app_strings_{LOCALE}.dart'),
                  encoding='utf-8').read()
    block = source[source.index('moodNames'):]
    block = block[:block.index('};')]
    return dict(re.findall(r"'(\w+)':\s*'([^']+)'", block))


names = mood_names()
state = {
    'version': 1,
    'locale': LOCALE,
    'today': TODAY,
    'moods': [{'id': m, 'name': names[m]} for m in MOODS],
}
with tempfile.NamedTemporaryFile(suffix='.plist', delete=False) as handle:
    plistlib.dump({'watch.state.v1': state}, handle)

sh('xcrun', 'simctl', 'terminate', UDID, BUNDLE)
sh('xcrun', 'simctl', 'spawn', UDID, 'defaults', 'import', BUNDLE, handle.name)
sh('xcrun', 'simctl', 'launch', UDID, BUNDLE, '-AppleLanguages', f'({LOCALE})', '-AppleLocale', APPLE_LOCALE)
time.sleep(5)
sh('xcrun', 'simctl', 'io', UDID, 'screenshot', os.path.join(OUT, 'grid.png'))
os.unlink(handle.name)
print(f'captured watch {LOCALE} grid -> {OUT}/grid.png')
