#!/usr/bin/env python3
"""Compose App Store slides from simulator captures.

Needs Pillow (`pip install pillow`) and Google Chrome (headless) on macOS.

usage: python3 tool/screenshots/compose.py <device: iphone|ipad> [locale ...]
Reads  build/screenshots/shots/<device>/<locale>/<screen>.png   (from capture.py)
Writes build/screenshots/slides/<device>/<locale>/<NN>_<name>.png at the exact App Store size.
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

CANVAS = {'iphone': (1320, 2868), 'ipad': (2064, 2752)}[DEVICE]

# (screen file, background gradient, dark text?)
SLIDES = [
    ('01_calendar', 'calendar', ('#E8E1FF', '#F7E6FF'), True),
    ('02_moods', 'picker', ('#FFE1EC', '#FFC9DC'), True),
    ('03_summary', 'calendar', ('#DDF5E4', '#C4EBD0'), True),
    ('04_notes', 'note', ('#FFF0D3', '#FFDDA8'), True),
    ('05_reminders', 'reminders', ('#DDF1F7', '#C6E6F0'), True),
    ('06_privacy', 'calendar', ('#5F3DC4', '#6C63FF'), False),
]

TEXT = {
    'en': {
        '01_calendar': 'Your mood, in full color',
        '02_moods': '10 moods for every feeling',
        '03_summary': 'See your month and best streak',
        '04_notes': 'Add a note to any day',
        '05_reminders': 'A gentle daily reminder',
        '06_privacy': ('Private, on your device', 'Your moods are stored only on your device.'),
    },
    'es': {
        '01_calendar': 'Tu ánimo, a todo color',
        '02_moods': '10 moods para cada emoción',
        '03_summary': 'Tu mes y tu mejor racha',
        '04_notes': 'Añade una nota a cada día',
        '05_reminders': 'Un recordatorio diario y amable',
        '06_privacy': ('Privado y en tu dispositivo', 'Tus moods se guardan solo en tu dispositivo.'),
    },
    'de': {
        '01_calendar': 'Deine Stimmung in allen Farben',
        '02_moods': '10 Stimmungen für jedes Gefühl',
        '03_summary': 'Dein Monat und deine beste Serie',
        '04_notes': 'Eine Notiz zu jedem Tag',
        '05_reminders': 'Eine sanfte tägliche Erinnerung',
        '06_privacy': ('Privat, auf deinem Gerät', 'Deine Stimmungen bleiben nur auf deinem Gerät.'),
    },
    'fr': {
        '01_calendar': 'Votre humeur en couleurs',
        '02_moods': '10 humeurs pour chaque émotion',
        '03_summary': 'Votre mois et votre meilleure série',
        '04_notes': 'Une note pour chaque jour',
        '05_reminders': 'Un rappel quotidien en douceur',
        '06_privacy': ('Privé, sur votre appareil', 'Vos humeurs restent uniquement sur votre appareil.'),
    },
    'it': {
        '01_calendar': 'Il tuo umore a colori',
        '02_moods': '10 stati d’animo per ogni emozione',
        '03_summary': 'Il tuo mese e la tua serie migliore',
        '04_notes': 'Una nota per ogni giorno',
        '05_reminders': 'Un promemoria quotidiano gentile',
        '06_privacy': ('Privato, sul tuo dispositivo', 'I tuoi stati d’animo restano solo sul tuo dispositivo.'),
    },
}

# Layout per device (px on the final canvas).
if DEVICE == 'iphone':
    L = dict(frame_w=1140, bezel=26, frame_radius=150, top=640, head_top=170,
             head_sizes=((22, 124), (32, 108), (99, 92)), side=100,
             panel_w=1100)
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
         box-shadow:0 50px 120px rgba(36,18,110,.38),0 0 0 3px #26242f inset;">
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
    color = '#2A1A6B' if dark else '#FFFFFF'
    size = head_size(text)
    shot = os.path.join(BUILD, 'shots', DEVICE, locale, screen + '.png')
    body = ''
    top = L['top']
    head_top = L['head_top']

    if slide_id == '03_summary':
        (x0, y0, x1, y1), bg_px = find_cards(shot)
        im_w = Image.open(shot).width
        cy0 = find_calendar_top(shot)
        cw, ch = im_w, y1 - cy0
        pw = 1180 if DEVICE == 'iphone' else 1640
        scale = pw / cw
        panel_h = round(ch * scale)
        rgb = '#%02x%02x%02x' % bg_px
        panel_top = top + (60 if DEVICE == 'iphone' else 30)
        body = f'''
        <div style="position:absolute;left:{(W - pw) // 2}px;top:{panel_top}px;width:{pw}px;height:{panel_h}px;
             border-radius:72px;overflow:hidden;background:{rgb};
             box-shadow:0 60px 140px rgba(20,90,50,.32);">
          <div style="width:{pw}px;height:{panel_h}px;background:url(file://{shot}) no-repeat;
               background-size:{pw}px auto;background-position:0 -{round(cy0 * scale)}px;"></div>
        </div>'''
    elif slide_id == '06_privacy':
        head_top = 380
        top = 1180 if DEVICE == 'iphone' else 1000
        lock = f'''
        <svg style="position:absolute;left:{W // 2 - 90}px;top:{150 if DEVICE == 'iphone' else 110}px"
             width="180" height="180" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.7"
             stroke-linecap="round" stroke-linejoin="round">
          <rect x="4.5" y="10.5" width="15" height="10" rx="2.5" fill="rgba(255,255,255,.18)"/>
          <path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/><circle cx="12" cy="15.5" r="1.3" fill="#fff"/>
        </svg>'''
        body = lock + phone_html(shot, top)
    else:
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
