#!/usr/bin/env python3
"""Capture the Google Play screens for one Android emulator + locale.

Run the app first with `flutter run -t tool/screenshots/main.dart -d <serial>` on an
emulator (the entrypoint wipes the app's local data) and keep it installed.

usage: python3 tool/screenshots/capture_android.py <serial> <locale: en|es|de|fr|it>
Writes build/screenshots/shots/android/<locale>/<picker|calendar|day|insights|locked|reminders>.png
Buttons are found by position, like capture.py: `uiautomator dump` lists the clickable
nodes and the four tabs of the bottom bar are the lowest row of four
([calendar, insights, log, settings]). The app opens on the Log in the "Saved" state
(the seed has today's entry): Edit brings the grid back and the note pill sits above Save.
The language is set per app with `cmd locale set-app-locales`. Put the status bar in demo mode
first (clock 9:41, full battery, no notifications) with `adb shell am broadcast -a
com.android.systemui.demo -e command ...`.
"day" opens the detail of day 15 of the previous month (the seed gives it a note and a time),
"insights" is the Insights tab on the 30 day range and "locked" is the Log with the note lock on:
the app is a debug build, so `run-as` creates the `screenshot_lock` marker next to the Hive files.
"""
import datetime
import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

SERIAL, LOCALE = sys.argv[1:3]
PACKAGE = 'com.artlab.moodcalendar'
ADB = os.path.expanduser('~/Library/Android/sdk/platform-tools/adb')
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, 'build', 'screenshots', 'shots', 'android', LOCALE)
os.makedirs(OUT, exist_ok=True)


def adb(*args, binary=False):
    r = subprocess.run([ADB, '-s', SERIAL, *args], capture_output=True)
    return r.stdout if binary else r.stdout.decode(errors='replace')


def set_lock_marker(on):
    """app_flutter/screenshot_lock makes main.dart start with the note lock on."""
    path = 'app_flutter/screenshot_lock'
    adb('shell', 'run-as', PACKAGE, 'sh', '-c', f'touch {path}' if on else f'rm -f {path}')


def launch(lock=False):
    adb('shell', 'am', 'force-stop', PACKAGE)
    set_lock_marker(lock)
    adb('shell', 'cmd', 'locale', 'set-app-locales', PACKAGE, '--locales', LOCALE)
    time.sleep(1)
    adb('shell', 'am', 'start', '-n', PACKAGE + '/.MainActivity')
    time.sleep(6)
    for _ in range(20):  # wait until the bottom bar is on screen
        if len(tab_buttons()) >= 4:
            break
        time.sleep(1)
    time.sleep(1.5)


def buttons():
    """Clickable nodes as (x, y, w, h) in px, from a fresh uiautomator dump."""
    for _ in range(6):
        adb('shell', 'uiautomator', 'dump', '/sdcard/ui.xml')
        raw = adb('exec-out', 'cat', '/sdcard/ui.xml')
        try:
            root = ET.fromstring(raw[raw.index('<'):])
        except (ValueError, ET.ParseError):
            time.sleep(1)
            continue
        out = []
        for n in root.iter('node'):
            if n.get('clickable') == 'true' and n.get('package') == PACKAGE:
                x0, y0, x1, y1 = map(int, re.findall(r'\d+', n.get('bounds')))
                out.append((x0, y0, x1 - x0, y1 - y0))
        return out
    raise RuntimeError('uiautomator dump returned nothing')


def tap(x, y):
    adb('shell', 'input', 'tap', str(int(x)), str(int(y)))
    time.sleep(1.8)


def tap_button(b):
    tap(b[0] + b[2] / 2, b[1] + b[3] / 2)


def shot(name):
    png = adb('exec-out', 'screencap', '-p', binary=True)
    with open(os.path.join(OUT, name + '.png'), 'wb') as f:
        f.write(png)
    print('captured android', LOCALE, name)


def rows(bs, tol=24):
    groups = []
    for b in sorted(bs, key=lambda b: b[1]):
        if groups and b[1] - groups[-1][0][1] <= tol:
            groups[-1].append(b)
        else:
            groups.append([b])
    return groups


def screen_size():
    out = adb('shell', 'wm', 'size')
    w, h = map(int, re.findall(r'(\d+)x(\d+)', out)[-1])
    density = int(re.findall(r'\d+', adb('shell', 'wm', 'density'))[-1])
    return w, h, density / 160


def tab_buttons():
    """Bottom bar tabs, left to right: [calendar, insights, log, settings].

    Only a row of four buttons in the lower fifth of the screen counts: the trend range
    pills of Insights are four buttons too.
    """
    height = screen_size()[1]
    groups = [g for g in rows(buttons()) if len(g) == 4 and g[0][1] > height * 0.8]
    return sorted(groups[-1], key=lambda b: b[0]) if groups else []


def non_tab_rows():
    tabs = {tuple(b) for b in tab_buttons()}
    return rows([b for b in buttons() if tuple(b) not in tabs])


def edit_button():
    """Edit on the Saved card: second row above the bar, after the bell."""
    for _ in range(6):
        groups = non_tab_rows()
        if len(groups) >= 2:
            return groups[1][0]
        time.sleep(1)
    raise RuntimeError('edit button not found')


def calendar_header():
    """Calendar card header, left to right: [previous, month title, next]: the row with the wide button."""
    for _ in range(6):
        tabs = {tuple(b) for b in tab_buttons()}
        for g in rows([b for b in buttons() if tuple(b) not in tabs]):
            if any(b[2] > 400 for b in g):
                return sorted(g, key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('calendar header buttons not found')


DETAIL_DAY = 15  # keep in sync with _detailDay in tool/screenshots/main.dart


def day_cell(day):
    """Cell of `day` in the previous month, computed from the first cell of the grid.

    The grid has 7 columns, starts on Sunday and has an 8 dp gap between cells; the list of
    clickable nodes can come back incomplete, so only the first cell is trusted.
    """
    gap = 8 * screen_size()[2]
    today = datetime.date.today()
    first = (today.replace(day=1) - datetime.timedelta(days=1)).replace(day=1)
    first_weekday = first.weekday() % 7
    for _ in range(6):
        tabs = {tuple(b) for b in tab_buttons()}
        groups = rows([b for b in buttons() if tuple(b) not in tabs])
        header = next((i for i, g in enumerate(groups) if any(b[2] > 400 for b in g)), None)
        if header is not None and len(groups) > header + 1:
            x, y, w, h = sorted(groups[header + 1], key=lambda b: b[0])[0]
            index = first_weekday + day - 1
            col, row = index % 7, index // 7
            return (x + (col - first_weekday) * (w + gap), y + row * (h + gap), w, h)
        time.sleep(1)
    raise RuntimeError('calendar day cell not found')


# 1) log grid: Edit on the Saved card brings back the moods by category.
launch()
tap_button(edit_button())
time.sleep(1)
shot('picker')

# 2) calendar + summary (the previous month is fully seeded)
launch()
tap_button(tab_buttons()[0])
tap_button(calendar_header()[0])
time.sleep(1)
shot('calendar')

# 3) day detail
tap_button(day_cell(DETAIL_DAY))
time.sleep(1.5)
shot('day')

# 4) insights on the 30 day range (7 days has too little data in the seed)
launch()
tap_button(tab_buttons()[1])
time.sleep(2)
ranges = []
for _ in range(8):
    ranges = [g for g in non_tab_rows() if len(g) == 4]
    if ranges:
        break
    time.sleep(1)
if not ranges:
    raise RuntimeError('trend range pills not found')
tap_button(sorted(ranges[0], key=lambda b: b[0])[1])
time.sleep(1.5)
shot('insights')

# 5) the Log with the note lock on
launch(lock=True)
time.sleep(1)
shot('locked')

# 6) settings (reminders)
launch()
tap_button(tab_buttons()[3])
time.sleep(1.5)
shot('reminders')
