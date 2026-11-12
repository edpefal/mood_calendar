#!/usr/bin/env python3
"""Capture the App Store screens for one simulator + locale.

Run the app first with `flutter run -t tool/screenshots/main.dart -d <udid>`
and have an idb companion connected to that simulator (see CLAUDE.md).

usage: python3 tool/screenshots/capture.py <udid> <device: iphone|ipad> <locale: en|es|de|fr|it>
Writes build/screenshots/shots/<device>/<locale>/<picker|calendar|day|insights|locked|reminders>.png
Buttons are found by position (not label) so it works in every language.
The app opens on the Log, which shows today's entry (the seed has one) in the
"Saved" state: the "picker" shot taps Edit to get the grid of moods by category.
"day" opens the detail of day 15 of the previous month (the seed gives it a note
and a time), "insights" is the Insights tab and "locked" is the Log with the note
lock on (the app is launched with SIMCTL_CHILD_SCREENSHOT_LOCK=1).
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


def launch(lock=False):
    sh('xcrun', 'simctl', 'terminate', UDID, BUNDLE)
    time.sleep(1)
    env = dict(os.environ)
    if lock:
        env['SIMCTL_CHILD_SCREENSHOT_LOCK'] = '1'
    subprocess.run(['xcrun', 'simctl', 'launch', UDID, BUNDLE,
                    '-AppleLanguages', f'({LOCALE})', '-AppleLocale', APPLE_LOCALE],
                   capture_output=True, text=True, env=env)
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
    """Calendar card header, left to right: [previous, month title, next].

    It is the row that holds the wide "choose month and year" button: "view
    year" sits in a row above it and the day cells below. The current month has
    no enabled "next", so the caller only needs the leftmost one.
    """
    for _ in range(6):  # the tab switch may still be animating
        tabs = {tuple(b) for b in tab_buttons()}
        groups = rows([b for b in buttons() if tuple(b) not in tabs])
        for g in groups:
            if any(b[2] > 150 for b in g):
                return sorted(g, key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('calendar header buttons not found')


def open_calendar_previous_month():
    tap_button(tab_buttons()[0])  # calendar tab
    row = calendar_row_buttons()
    tap_button(row[0])  # previous month


DETAIL_DAY = 15  # keep in sync with _detailDay in tool/screenshots/main.dart


def day_cell(day):
    """Calendar cell of `day` in the visible (previous) month, as a button tuple.

    idb returns a truncated list for the day cells, so the position is computed
    from the first cell of the grid, which is always the 1st of the month: the
    grid has 7 columns, starts on Sunday and has an 8 pt gap between cells.
    """
    import datetime
    today = datetime.date.today()
    first = (today.replace(day=1) - datetime.timedelta(days=1)).replace(day=1)
    first_weekday = first.weekday() % 7  # DateTime.weekday % 7 in the app: Sunday = 0
    for _ in range(6):
        tabs = {tuple(b) for b in tab_buttons()}
        groups = rows([b for b in buttons() if tuple(b) not in tabs])
        header = next((i for i, g in enumerate(groups) if any(b[2] > 150 for b in g)), None)
        if header is not None and len(groups) > header + 1:
            x, y, w, h, _label = sorted(groups[header + 1], key=lambda b: b[0])[0]
            index = first_weekday + day - 1
            col, row = index % 7, index // 7
            return (x + (col - first_weekday) * (w + 8), y + row * (h + 8), w, h, '')
        time.sleep(1)
    raise RuntimeError('calendar day cell not found')


# 1) log grid: Edit on the Saved card brings back the moods by category.
launch()
tap_button(edit_button())
time.sleep(1)
shot('picker')

# 2) calendar + summary (previous month is fully seeded)
launch()
open_calendar_previous_month()
time.sleep(1)
shot('calendar')

# 3) day detail: tap a day with an entry (it has a note and the time it was logged)
tap_button(day_cell(DETAIL_DAY))
time.sleep(1.5)
shot('day')

# 4) insights
launch()
tap_button(tab_buttons()[1])  # insights tab
time.sleep(2)
shot('insights')

# 5) the Log with the note lock on: today's note shows "Note locked"
launch(lock=True)
time.sleep(1)
shot('locked')

# 6) settings screen (reminders)
launch()
tap_button(tab_buttons()[3])  # settings tab
time.sleep(1.5)
shot('reminders')
