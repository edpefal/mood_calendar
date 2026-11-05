#!/usr/bin/env python3
"""Capture the App Store screens for one simulator + locale.

Run the app first with `flutter run -t tool/screenshots/main.dart -d <udid>`
and have an idb companion connected to that simulator (see CLAUDE.md).

usage: python3 tool/screenshots/capture.py <udid> <device: iphone|ipad> <locale: en|es|de|fr|it>
Writes build/screenshots/shots/<device>/<locale>/<picker|note|calendar|reminders>.png
Buttons are found by position (not label) so it works in every language.
The app opens on the Log, which shows today's entry (the seed has one) in the
"Saved" state: the "picker" shot taps Edit to get the grid of moods by category,
and the note editor is opened with the note pill above Save.
The four tabs of the bottom bar are the bottom-most row of buttons:
[calendar, insights, log, settings].
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
    for _ in range(20):  # wait until the bottom bar is on screen
        if len(tab_buttons()) >= 4:
            break
        time.sleep(1)
    time.sleep(1.5)


def elements():
    # describe-all returns nothing while the app is (re)launching.
    for _ in range(10):
        out = sh('idb', 'ui', 'describe-all', '--udid', UDID)
        try:
            return json.loads(out)
        except json.JSONDecodeError:
            time.sleep(1)
    raise RuntimeError('idb ui describe-all returned no data')


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


def rows(bs):
    """Group buttons into rows (same y within 8 pt), top to bottom."""
    groups = []
    for b in sorted(bs, key=lambda b: b[1]):
        if groups and b[1] - groups[-1][0][1] <= 8:
            groups[-1].append(b)
        else:
            groups.append([b])
    return groups


def tab_buttons():
    """Bottom bar tabs, left to right: [calendar, insights, log, settings]."""
    groups = [g for g in rows(buttons()) if len(g) == 4]
    return sorted(groups[-1], key=lambda b: b[0]) if groups else []


def non_tab_rows():
    tabs = {tuple(b) for b in tab_buttons()}
    return rows([b for b in buttons() if tuple(b) not in tabs])


def edit_button():
    """Edit button of the Saved card on the Log.

    Rows of buttons above the bar, top to bottom: [bell], [Edit], and, when
    yesterday has no entry, ["Forgot yesterday? Log it"]. Edit is the second.
    """
    for _ in range(6):
        groups = non_tab_rows()
        if len(groups) >= 2:
            return groups[1][0]
        time.sleep(1)
    raise RuntimeError('edit button not found')


def note_pill():
    """Note pill of the Log grid: the row just above Save (the last row)."""
    for _ in range(6):
        groups = non_tab_rows()
        if len(groups) >= 2:
            return groups[-2][0]
        time.sleep(1)
    raise RuntimeError('note pill not found')


def calendar_row_buttons():
    """Calendar card header, left to right: [previous, next].

    It is the topmost row of buttons once the bottom bar row is excluded (the
    day cells sit below it). The current month has no enabled "next", so the
    caller only needs the leftmost one.
    """
    for _ in range(6):  # the tab switch may still be animating
        tabs = {tuple(b) for b in tab_buttons()}
        rest = [b for b in buttons() if tuple(b) not in tabs]
        groups = rows(rest)
        if groups:
            return sorted(groups[0], key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('calendar header buttons not found')


def open_calendar_previous_month():
    tap_button(tab_buttons()[0])  # calendar tab
    row = calendar_row_buttons()
    tap_button(row[0])  # previous month


# 1) log grid: Edit on the Saved card brings back the moods by category.
launch()
tap_button(edit_button())
time.sleep(1)
shot('picker')

# 2) note editor, opened with the pill above Save
launch()
tap_button(edit_button())
tap_button(note_pill())
time.sleep(1.5)
shot('note')

# 3) calendar + summary (previous month is fully seeded)
launch()
open_calendar_previous_month()
time.sleep(1)
shot('calendar')

# 4) settings screen (reminders)
launch()
tap_button(tab_buttons()[3])  # settings tab
time.sleep(1.5)
shot('reminders')
