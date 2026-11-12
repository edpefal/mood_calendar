#!/usr/bin/env python3
"""Compose App Store slides from simulator captures.

Needs Pillow (`pip install pillow`) and Google Chrome (headless) on macOS.

usage: python3 tool/screenshots/compose.py <device: iphone|ipad|android> [locale ...]
Reads  build/screenshots/shots/<device>/<locale>/<screen>.png   (from capture.py)
Writes build/screenshots/slides/<device>/<locale>/<NN>_<name>.png at the exact App Store size.

`android` composes Google Play phone slides (1080x1920, 9:16) from the emulator captures
made with `capture_android.py` (shots/android/<locale>/).
"""
import html
import os
import subprocess
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(os.path.dirname(os.path.dirname(HERE)), 'build', 'screenshots')
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
DEVICE = sys.argv[1]
LOCALES = sys.argv[2:] or ['en', 'es', 'de', 'fr', 'it']

CANVAS = {'iphone': (1320, 2868), 'ipad': (2064, 2752), 'android': (1080, 1920)}[DEVICE]

# (slide id, capture file, background gradient, dark text?)
# Pastel gradients from the app's mesh background; headlines in the app's ink.
SLIDES = [
    ('01_log', 'picker', ('#FFE9C9', '#FFD7E8'), True),
    ('02_calendar', 'calendar', ('#D8F3E6', '#E9E4FF'), True),
    ('03_day', 'day', ('#E7E0FF', '#D6EBFF'), True),
    ('04_insights', 'insights', ('#D6EBFF', '#E9E0FF'), True),
    ('05_notes', 'locked', ('#FFDDEB', '#E4DAFF'), True),
    ('06_reminders', 'reminders', ('#D9F5E8', '#FFF0D2'), True),
]

TEXT = {
    'en': {
        '01_log': 'Name how you feel',
        '02_calendar': 'See your month in color',
        '03_day': 'Remember how each day felt',
        '04_insights': 'Understand your patterns',
        '05_notes': 'Keep your notes private',
        '06_reminders': 'A gentle daily reminder',
    },
    'es': {
        '01_log': 'Ponle nombre a lo que sientes',
        '02_calendar': 'Tu mes, a todo color',
        '03_day': 'Recuerda cómo fue cada día',
        '04_insights': 'Entiende tus patrones',
        '05_notes': 'Mantén tus notas privadas',
        '06_reminders': 'Un recordatorio diario y amable',
    },
    'de': {
        '01_log': 'Benenne, wie du dich fühlst',
        '02_calendar': 'Dein Monat in Farbe',
        '03_day': 'Erinnere dich an jeden Tag',
        '04_insights': 'Verstehe deine Muster',
        '05_notes': 'Halte deine Notizen privat',
        '06_reminders': 'Eine sanfte tägliche Erinnerung',
    },
    'fr': {
        '01_log': 'Mettez des mots sur vos émotions',
        '02_calendar': 'Votre mois en couleurs',
        '03_day': 'Souvenez-vous de chaque jour',
        '04_insights': 'Comprenez vos habitudes',
        '05_notes': 'Gardez vos notes privées',
        '06_reminders': 'Un rappel quotidien en douceur',
    },
    'it': {
        '01_log': 'Dai un nome a ciò che senti',
        '02_calendar': 'Il tuo mese a colori',
        '03_day': 'Ricorda com’è andato ogni giorno',
        '04_insights': 'Scopri i tuoi andamenti',
        '05_notes': 'Tieni private le tue note',
        '06_reminders': 'Un promemoria quotidiano gentile',
    },
}

# Layout per device (px on the final canvas).
if DEVICE == 'iphone':
    L = dict(frame_w=1140, bezel=26, frame_radius=150, top=640, head_top=170,
             head_sizes=((22, 124), (32, 108), (99, 92)), side=100,
             panel_w=1100)
elif DEVICE == 'android':
    L = dict(frame_w=900, bezel=20, frame_radius=84, top=450, head_top=110,
             head_sizes=((22, 96), (32, 84), (99, 72)), side=80,
             panel_w=900)
else:
    L = dict(frame_w=1560, bezel=30, frame_radius=96, top=560, head_top=150,
             head_sizes=((22, 150), (32, 132), (99, 112)), side=120,
             panel_w=1560)


def head_size(text):
    for limit, size in L['head_sizes']:
        if len(text) <= limit:
            return size
    return L['head_sizes'][-1][1]


def find_cards(path):
    """Bounding box (x0, y0, x1, y1) of the two summary cards in a calendar capture."""
    im = Image.open(path).convert('RGB')
    w, h = im.size
    bg = im.getpixel((w // 2, h - 6))

    def differs(p):
        return sum(abs(p[i] - bg[i]) for i in range(3)) > 40

    rows = [y for y in range(int(h * 0.55), h - 10) if differs(im.getpixel((w // 2, y)))]
    y0, y1 = min(rows), max(rows)
    mid = (y0 + y1) // 2
    xs = [x for x in range(w) if differs(im.getpixel((x, y0 + 40)))]
    return (max(min(xs) - 24, 0), max(y0 - 24, 0), min(max(xs) + 24, w), min(y1 + 24, h)), bg


def find_calendar_top(path):
    """First row (below the status bar) where the calendar card starts."""
    im = Image.open(path).convert('RGB')
    w, h = im.size
    bg = im.getpixel((w // 2, h - 6))
    for y in range(int(h * 0.07), int(h * 0.5)):
        p = im.getpixel((w // 2, y))
        if sum(abs(p[i] - bg[i]) for i in range(3)) > 12:
            return max(y - 24, 0)
    return int(h * 0.12)


def phone_html(img_path, top, shift=0, zoom=1.0, fill=None):
    """Device frame with the capture inside.

    shift/zoom: hide `shift` px (of the original capture) above the frame and
    magnify the capture; with `fill` the frame bleeds off the bottom edge and the
    area below the capture is painted with that colour.
    """
    fw, bz = L['frame_w'], L['bezel']
    sw = fw - 2 * bz
    left = (CANVAS[0] - fw) // 2
    im = Image.open(img_path)
    scale = sw / im.width * zoom
    iw, ih = round(im.width * scale), round(im.height * scale)
    off = round(shift * scale)
    if fill:
        screen_h = CANVAS[1] - top + 300
        bg = f'background:{fill};'
    else:
        screen_h = ih - off
        bg = ''
    return f'''
    <div style="position:absolute;left:{left}px;top:{top}px;width:{fw}px;height:{screen_h + 2 * bz}px;
         background:#0c0b12;border-radius:{L['frame_radius']}px;
         box-shadow:0 50px 120px rgba(0,40,46,.38),0 0 0 3px #26242f inset;">
      <div style="position:absolute;left:{bz}px;top:{bz}px;width:{sw}px;height:{screen_h}px;overflow:hidden;{bg}
           border-radius:{L['frame_radius'] - bz}px;">
        <img src="file://{img_path}" style="position:absolute;left:-{(iw - sw) // 2}px;top:-{off}px;width:{iw}px;height:{ih}px;display:block;">
      </div>
    </div>'''


def page(slide_id, screen, bg, dark, locale):
    W, H = CANVAS
    text = TEXT[locale][slide_id]
    sub = None
    if isinstance(text, tuple):
        text, sub = text
    color = '#1D1D22' if dark else '#FFFFFF'
    size = head_size(text)
    shot = os.path.join(BUILD, 'shots', DEVICE, locale, screen + '.png')
    body = ''
    top = L['top']
    head_top = L['head_top']

    body = phone_html(shot, top)

    sub_html = ''
    if sub:
        sub_html = f'''<div style="position:absolute;left:{L['side']}px;right:{L['side']}px;
            top:{head_top + round(size * 1.12 * 2) + 24}px;text-align:center;font-weight:500;
            font-size:{round(size * 0.42)}px;line-height:1.3;color:rgba(255,255,255,.88);">{html.escape(sub)}</div>'''

    return f'''<!doctype html><html><head><meta charset="utf-8">
<style>
{open(os.path.join(HERE, 'fonts.css')).read().replace('url(fonts/', 'url(file://' + os.path.join(HERE, 'fonts') + '/')}
html,body{{margin:0;padding:0;width:{W}px;height:{H}px;overflow:hidden;font-family:'Poppins',sans-serif;}}
body{{background:linear-gradient(160deg,{bg[0]} 0%,{bg[1]} 100%);position:relative;}}
.h{{position:absolute;left:{L['side']}px;right:{L['side']}px;top:{head_top}px;text-align:center;
   font-weight:700;font-size:{size}px;line-height:1.12;color:{color};letter-spacing:-0.01em;}}
</style></head><body>
<div class="h">{html.escape(text)}</div>
{sub_html}
{body}
</body></html>'''


def render(slide_id, screen, bg, dark, locale):
    shot = os.path.join(BUILD, 'shots', DEVICE, locale, screen + '.png')
    if not os.path.exists(shot):
        print('skip (missing capture):', DEVICE, locale, slide_id)
        return
    out_dir = os.path.join(BUILD, 'slides', DEVICE, locale)
    os.makedirs(out_dir, exist_ok=True)
    html_path = os.path.join(out_dir, slide_id + '.html')
    with open(html_path, 'w') as f:
        f.write(page(slide_id, screen, bg, dark, locale))
    png = os.path.join(out_dir, slide_id + '.png')
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
                    '--force-device-scale-factor=1', f'--window-size={CANVAS[0]},{CANVAS[1]}',
                    '--allow-file-access-from-files', '--virtual-time-budget=4000',
                    f'--screenshot={png}', 'file://' + html_path],
                   capture_output=True, text=True)
    size = Image.open(png).size
    flag = '' if size == CANVAS else f'  !! expected {CANVAS}'
    print('rendered', DEVICE, locale, slide_id, size, flag)


for locale in LOCALES:
    for slide_id, screen, bg, dark in SLIDES:
        render(slide_id, screen, bg, dark, locale)
