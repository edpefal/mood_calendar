#!/usr/bin/env python3
"""Capture the Google Play screens for one Android emulator + locale.

Run the app first with `flutter run -t tool/screenshots/main.dart -d <serial>` on an
emulator (the entrypoint wipes the app's local data) and keep it installed.

usage: python3 tool/screenshots/capture_android.py <serial> <locale: en|es|de|fr|it>
Writes build/screenshots/shots/android/<locale>/<picker|note|calendar|reminders>.png
Buttons are found by position, like capture.py: `uiautomator dump` lists the clickable
nodes and the four tabs of the bottom bar are the lowest row of four.
The language is set per app with `cmd locale set-app-locales`. Put the status bar in demo mode
first (clock 9:41, full battery, no notifications) with `adb shell am broadcast -a
com.android.systemui.demo -e command ...`; the caret handle left in the note is painted over.
"""
import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw

SERIAL, LOCALE = sys.argv[1:3]
PACKAGE = 'com.artlab.moodcalendar'
ADB = os.path.expanduser('~/Library/Android/sdk/platform-tools/adb')
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, 'build', 'screenshots', 'shots', 'android', LOCALE)
os.makedirs(OUT, exist_ok=True)


def adb(*args, binary=False):
    r = subprocess.run([ADB, '-s', SERIAL, *args], capture_output=True)
    return r.stdout if binary else r.stdout.decode(errors='replace')


def launch():
    adb('shell', 'am', 'force-stop', PACKAGE)
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


def clean_note(path):
    """Paint over the text-selection handle (purple drop) that Android leaves under the caret."""
    im = Image.open(path).convert('RGB')
    w, h = im.size
    px = im.load()
    xs, ys = [], []
    for y in range(int(h * 0.12), int(h * 0.55)):
        for x in range(int(w * 0.08), int(w * 0.92)):
            r, g, b = px[x, y]
            if b - g > 55 and r < 150 and b > 120:  # purple, not the dark text
                xs.append(x)
                ys.append(y)
    if xs:
        pad = 10
        ImageDraw.Draw(im).rectangle(
            (min(xs) - pad, min(ys) - pad, max(xs) + pad, max(ys) + pad), fill=(255, 255, 255))
    im.save(path)


def rows(bs, tol=24):
    groups = []
    for b in sorted(bs, key=lambda b: b[1]):
        if groups and b[1] - groups[-1][0][1] <= tol:
            groups[-1].append(b)
        else:
            groups.append([b])
    return groups


def tab_buttons():
    """Bottom bar tabs, left to right: [mood picker, calendar, store, settings]."""
    groups = [g for g in rows(buttons()) if len(g) == 4]
    return sorted(groups[-1], key=lambda b: b[0]) if groups else []


def non_tab_rows():
    tabs = {tuple(b) for b in tab_buttons()}
    return rows([b for b in buttons() if tuple(b) not in tabs])


def note_button():
    for _ in range(6):
        groups = non_tab_rows()
        if groups:
            return max(groups[0], key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('note button not found')


def next_arrow():
    for _ in range(6):
        groups = non_tab_rows()
        if len(groups) >= 5:  # arrows row is third from the bottom: [..., arrows, grid, save]
            return max(groups[-3], key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('next arrow not found')


def calendar_previous():
    for _ in range(6):
        groups = non_tab_rows()
        if groups:
            return min(groups[0], key=lambda b: b[0])
        time.sleep(1)
    raise RuntimeError('calendar header buttons not found')


NEXT_TAPS = 6

launch()
arrow = next_arrow()
for _ in range(NEXT_TAPS):
    tap_button(arrow)
time.sleep(1)
shot('picker')

launch()
tap_button(note_button())
time.sleep(7)  # lets the caret handle fade out
shot('note')
clean_note(os.path.join(OUT, 'note.png'))

launch()
tap_button(tab_buttons()[1])  # calendar tab
tap_button(calendar_previous())  # previous month is fully seeded
time.sleep(1)
shot('calendar')

launch()
tap_button(tab_buttons()[3])  # settings tab
time.sleep(1.5)
shot('reminders')
