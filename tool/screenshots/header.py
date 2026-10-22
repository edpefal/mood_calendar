#!/usr/bin/env python3
"""Compose the App Store product page header / search results art (16:9, 5244x2950).

usage: python3 tool/screenshots/header.py [--play] [locale ...]   (default: en es de fr it)
Writes aso/header/<locale>/header_search_5244x2950.png (opaque PNG, no alpha).
With --play it writes the Google Play feature graphic instead, aso/play/<locale>/feature_1024x500.png
(1024x500, opaque PNG): same look, rendered at 2x and scaled down.
Key content stays inside the center 4425x2247 so both the 21:9 header and
the 3:2 search crops show it intact.
"""
import os
import subprocess
import sys
import tempfile

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
PLAY = '--play' in sys.argv
LOCALES = [a for a in sys.argv[1:] if a != '--play'] or ['en', 'es', 'de', 'fr', 'it']
TAGLINE = {
    'en': 'Track your mood, every day',
    'es': 'Registra tu ánimo, cada día',
    'de': 'Verfolge deine Stimmung, jeden Tag',
    'fr': 'Suivez votre humeur, chaque jour',
    'it': 'Tieni traccia del tuo umore, ogni giorno',
}
W, H = 5244, 2950
moods = ['happy', 'calm', 'neutral', 'sad', 'angry', 'anxious', 'brave', 'confident', 'romantic', 'shy']
icon = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png')
faces = ''.join(
    f'<img src="file://{ROOT}/assets/icon/{m}.svg">' for m in moods if m != 'brave')  # brave.svg is heavy

def render(loc):
    page = f'''<!doctype html><meta charset="utf-8"><style>
    @font-face{{font-family:P;font-weight:700;src:url(file://{HERE}/fonts/poppins-700.woff2)}}
    @font-face{{font-family:P;font-weight:500;src:url(file://{HERE}/fonts/poppins-500.woff2)}}
    html,body{{margin:0;width:{W}px;height:{H}px;overflow:hidden}}
    body{{background:linear-gradient(135deg,#5F3DC4,#6C63FF);font-family:P;color:#fff;
     display:flex;flex-direction:column;align-items:center;justify-content:center;gap:90px}}
    .top{{display:flex;align-items:center;gap:150px}}
    .top img{{width:640px;height:640px;border-radius:144px;box-shadow:0 40px 120px #0004}}
    h1{{font-size:300px;margin:0;line-height:1}}
    p{{font-size:120px;font-weight:500;margin:30px 0 0;opacity:.95}}
    .row{{display:flex;gap:70px}}
    .row img{{width:290px;height:290px;background:#fff;border-radius:50%;padding:30px;box-sizing:border-box;box-shadow:0 20px 60px #0003}}
    </style><body>
    <div class="top"><img src="file://{icon}"><div><h1>Mood Calendar</h1><p>{TAGLINE[loc]}</p></div></div>
    <div class="row">{faces}</div></body>'''
    OUT = os.path.join(ROOT, 'aso', 'header', loc, 'header_search_5244x2950.png')
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    tmp = os.path.join(os.path.dirname(OUT), '_header.html')
    open(tmp, 'w').write(page)
    subprocess.run([CHROME, '--headless', '--disable-gpu', f'--user-data-dir={tempfile.mkdtemp()}', '--hide-scrollbars', '--force-device-scale-factor=1',
                    f'--window-size={W},{H}', f'--screenshot={OUT}', f'file://{tmp}'], check=True, timeout=180,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    os.remove(tmp)
    Image.open(OUT).convert('RGB').save(OUT)
    return Image.open(OUT).size



def render_play(loc):
    pw, ph = 2048, 1000  # 2x of 1024x500
    page = f'''<!doctype html><meta charset="utf-8"><style>
    @font-face{{font-family:P;font-weight:700;src:url(file://{HERE}/fonts/poppins-700.woff2)}}
    @font-face{{font-family:P;font-weight:500;src:url(file://{HERE}/fonts/poppins-500.woff2)}}
    html,body{{margin:0;width:{pw}px;height:{ph}px;overflow:hidden}}
    body{{background:linear-gradient(135deg,#5F3DC4,#6C63FF);font-family:P;color:#fff;
     display:flex;flex-direction:column;align-items:center;justify-content:center;gap:70px}}
    .top{{display:flex;align-items:center;gap:90px}}
    .top img{{width:300px;height:300px;border-radius:68px;box-shadow:0 20px 60px #0004}}
    h1{{font-size:140px;margin:0;line-height:1}}
    p{{font-size:58px;font-weight:500;margin:14px 0 0;opacity:.95}}
    .row{{display:flex;gap:34px}}
    .row img{{width:140px;height:140px;background:#fff;border-radius:50%;padding:15px;box-sizing:border-box;box-shadow:0 10px 30px #0003}}
    </style><body>
    <div class="top"><img src="file://{icon}"><div><h1>Mood Calendar</h1><p>{TAGLINE[loc]}</p></div></div>
    <div class="row">{faces}</div></body>'''
    out = os.path.join(ROOT, 'aso', 'play', loc, 'feature_1024x500.png')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    tmp = os.path.join(os.path.dirname(out), '_feature.html')
    open(tmp, 'w').write(page)
    big = os.path.join(os.path.dirname(out), '_feature_2x.png')
    subprocess.run([CHROME, '--headless', '--disable-gpu', f'--user-data-dir={tempfile.mkdtemp()}', '--hide-scrollbars', '--force-device-scale-factor=1',
                    f'--window-size={pw},{ph}', f'--screenshot={big}', f'file://{tmp}'], check=True, timeout=180,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    Image.open(big).convert('RGB').resize((1024, 500), Image.LANCZOS).save(out)
    os.remove(tmp)
    os.remove(big)
    return Image.open(out).size


for loc in LOCALES:
    print(loc, render_play(loc) if PLAY else render(loc))
