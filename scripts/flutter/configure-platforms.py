#!/usr/bin/env python3
"""Configurazione idempotente dei runner generati da Flutter."""
from pathlib import Path
import plistlib
root = Path(__file__).resolve().parents[2]
for path in (root / 'macos/Runner').glob('*.entitlements'):
    with path.open('rb') as source:
        data = plistlib.load(source)
    data['com.apple.security.files.user-selected.read-write'] = True
    with path.open('wb') as target:
        plistlib.dump(data, target)
for platform in ('ios', 'macos'):
    path = root / platform / 'Runner/Info.plist'
    if path.exists():
        with path.open('rb') as source:
            data = plistlib.load(source)
        data['CFBundleDisplayName'] = 'Diario KH'
        data['CFBundleName'] = 'Diario KH'
        if platform == 'ios':
            schemes = data.get('LSApplicationQueriesSchemes', [])
            data['LSApplicationQueriesSchemes'] = sorted(set(schemes + ['http', 'https']))
        with path.open('wb') as target:
            plistlib.dump(data, target)
path = root / 'android/app/src/main/AndroidManifest.xml'
if path.exists():
    text = path.read_text().replace('android:label="kh_diario"', 'android:label="Diario KH"')
    path.write_text(text)
