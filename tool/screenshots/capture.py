#!/usr/bin/env python3
"""Capture the App Store screens for one simulator + locale.

Run the app first with `flutter run -t tool/screenshots/main.dart -d <udid>`
and have an idb companion connected to that simulator (see CLAUDE.md).

usage: python3 tool/screenshots/capture.py <udid> <device: iphone|ipad> <locale: en|es|de|fr|it>
Writes build/screenshots/shots/<device>/<locale>/<picker|note|calendar|reminders>.png
Buttons are found by position (not label) so it works in every language.
"""
import json
import os
import subprocess
import sys
import time

UDID, DEVICE, LOCALE = sys.argv[1:4]
BUNDLE = 'com.artlab.moodcalendar'
APPLE_LOCALE = {'en': 'en_US', 'es': 'es_ES', 'de': 'de_DE', 'fr': 'fr_FR', 'it': 'it_IT'}[LOCALE]
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, 'build', 'screenshots', 'shots', DEVICE, LOCALE)
os.makedirs(OUT, exist_ok=True)


def sh(*args):
    return subprocess.run(args, capture_output=True, text=True).stdout


def launch():
    sh('xcrun', 'simctl', 'terminate', UDID, BUNDLE)
    time.sleep(1)
    sh('xcrun', 'simctl', 'launch', UDID, BUNDLE,
       '-AppleLanguages', f'({LOCALE})', '-AppleLocale', APPLE_LOCALE)
    time.sleep(5)
    for _ in range(20):  # wait until the home header is on screen
        if len([b for b in buttons() if b[1] < 160]) >= 2:
            break
        time.sleep(1)
    time.sleep(1.5)


def elements():
    return json.loads(sh('idb', 'ui', 'describe-all', '--udid', UDID))


def buttons():
    out = []
    for e in elements():
        if e.get('type') == 'Button':
            f = e['frame']
            out.append((f['x'], f['y'], f['width'], f['height'], e.get('AXLabel') or ''))
    return out


def tap(x, y):
    sh('idb', 'ui', 'tap', '--udid', UDID, str(int(x)), str(int(y)))
    time.sleep(1.8)


def tap_button(b):
    tap(b[0] + b[2] / 2, b[1] + b[3] / 2)


def shot(name):
    sh('xcrun', 'simctl', 'io', UDID, 'screenshot', os.path.join(OUT, name + '.png'))
    print('captured', DEVICE, LOCALE, name)


def header_buttons():
    """Home screen header buttons, left to right: [store, calendar, settings]."""
    bs = sorted((b for b in buttons() if b[1] < 160), key=lambda b: b[0])
    return bs


def calendar_row_buttons():
    """Calendar card header, left to right: [previous, next].

    Found as the topmost group of 2+ buttons sharing the same y ("back to
    today" is alone above it; the current month has no "next" button, so only
    past months have this group). Works on any screen size.
    """
    for _ in range(6):  # the route transition may still be running
        groups = []
        for b in sorted(buttons(), key=lambda b: b[1]):
            if groups and b[1] - groups[-1][0][1] <= 8:
                groups[-1].append(b)
            else:
                groups.append([b])
        for group in groups:
            if len(group) >= 2:
                return sorted(group, key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('calendar header buttons not found')


def open_calendar_previous_month():
    hb = header_buttons()
    tap_button(hb[-2])  # calendar is the middle header button, settings the last
    row = calendar_row_buttons()
    tap_button(row[0])  # previous month


# 1) mood picker: swipe to a colorful premium mood
launch()
els = elements()
page = max((e for e in els if e.get('type') == 'GenericElement'),
           key=lambda e: e['frame']['width'] * e['frame']['height'])
fx, fy, fw, fh = (page['frame'][k] for k in ('x', 'y', 'width', 'height'))
cy = fy + fh / 2
for _ in range(8):
    sh('idb', 'ui', 'swipe', '--udid', UDID, str(int(fx + fw * 0.85)), str(int(cy)),
       str(int(fx + fw * 0.15)), str(int(cy)), '--duration', '0.25')
    time.sleep(0.7)
time.sleep(1)
shot('picker')

# 2) note editor
launch()
note_btn = sorted((b for b in buttons() if b[1] > 600), key=lambda b: b[1])[0]
tap_button(note_btn)
time.sleep(1.5)
shot('note')

# 3) calendar + summary (previous month is fully seeded)
launch()
open_calendar_previous_month()
time.sleep(1)
shot('calendar')

# 4) settings screen (reminders)
launch()
tap_button(header_buttons()[-1])  # settings is the rightmost header button
time.sleep(1.5)
shot('reminders')
