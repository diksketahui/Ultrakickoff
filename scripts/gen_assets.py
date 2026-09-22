#!/usr/bin/env python3
"""Generate logo klub (versi palsu/fiktif) + trofi sebagai SVG.
Murni stdlib, tanpa unduh apa pun. Jalankan: python3 scripts/gen_assets.py
Output: godot/assets/logos/<id>.svg (38 klub), godot/assets/trophies/*.svg
"""
import os

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "godot", "assets")
LOGOS = os.path.join(ROOT, "logos")
TROPHIES = os.path.join(ROOT, "trophies")

LIGA_SUPER = [
    ("S0", "Persib Bandung"), ("S1", "Persija Jakarta"), ("S2", "Persebaya Surabaya"),
    ("S3", "Borneo Samarinda"), ("S4", "Bali United"), ("S5", "Dewa United Banten"),
    ("S6", "PSM Makassar"), ("S7", "Arema FC"), ("S8", "PSIM Yogyakarta"),
    ("S9", "Persijap Jepara"), ("S10", "Bhayangkara Lampung"), ("S11", "Persita Tangerang"),
    ("S12", "Persik Kediri"), ("S13", "Madura United"), ("S14", "Malut United"),
    ("S15", "Persis Solo"), ("S16", "PSBS Biak"), ("S17", "Semen Padang"),
]
CHAMPIONSHIP = [
    "PSS Sleman", "Barito Putera", "PSIS Semarang", "Persipura Jayapura",
    "Adhyaksa Banten", "Garudayaksa FC", "Sumsel United", "Bekasi City",
    "Persiraja Banda Aceh", "PSMS Medan", "Persikad Depok", "PSPS Pekanbaru",
    "Persekat Tegal", "Sriwijaya FC", "Persela Lamongan", "Deltras Sidoarjo",
    "Persiku Kudus", "Persiba Balikpapan", "Persipal Palu", "Kendal Tornado",
]


def initials(name):
    parts = [w for w in name.replace("FC", "").split(" ") if w]
    s = "".join(w[0] for w in parts)[:3]
    return s.upper() or "UK"


def hue_of(key):
    return sum(ord(c) * (i + 3) for i, c in enumerate(key)) % 360


def logo_svg(club_id, name):
    hue = hue_of(club_id + name)
    ini = initials(name)
    fs = 34 if len(ini) <= 2 else 26
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><rect width="128" height="128" rx="22" fill="#0b1220"/><path d="M64 10 L104 25 V60 C104 89 87 106 64 117 C41 106 24 89 24 60 V25 Z" fill="hsl({hue},55%,26%)" stroke="hsl({hue},80%,62%)" stroke-width="5" stroke-linejoin="round"/><path d="M24 60 H104" stroke="hsl({hue},80%,62%)" stroke-opacity="0.5" stroke-width="3"/><text x="64" y="72" font-family="sans-serif" font-size="{fs}" font-weight="bold" fill="#ffffff" text-anchor="middle">{ini}</text><circle cx="64" cy="96" r="9" fill="#f5f7fa" stroke="#101828" stroke-width="2"/></svg>
"""


def trophy_cup():
    return """<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><rect width="128" height="128" rx="22" fill="#0b1220"/><path d="M44 18 H84 V22 H44 Z" fill="#e8b64c"/><path d="M46 22 H82 L76 62 H52 Z" fill="#f2cd72" stroke="#9a7418" stroke-width="3" stroke-linejoin="round"/><path d="M46 30 C26 30 26 58 48 60" fill="none" stroke="#e8b64c" stroke-width="6" stroke-linecap="round"/><path d="M82 30 C102 30 102 58 80 60" fill="none" stroke="#e8b64c" stroke-width="6" stroke-linecap="round"/><rect x="58" y="62" width="12" height="14" fill="#e8b64c"/><rect x="46" y="76" width="36" height="10" rx="3" fill="#e8b64c"/><rect x="38" y="86" width="52" height="12" rx="3" fill="#9a7418"/><circle cx="64" cy="42" r="8" fill="#0b1220" opacity="0.25"/></svg>
"""


def trophy_boot():
    return """<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><rect width="128" height="128" rx="22" fill="#0b1220"/><path d="M40 24 H62 V58 L96 72 V78 H96 C96 88 88 94 78 94 H40 Z" fill="#f2cd72" stroke="#9a7418" stroke-width="3" stroke-linejoin="round"/><path d="M62 34 H72 M62 44 H76 M62 54 H70" stroke="#9a7418" stroke-width="3" stroke-linecap="round"/><rect x="34" y="94" width="68" height="10" rx="4" fill="#e8b64c"/><circle cx="96" cy="40" r="10" fill="#e8b64c"/><text x="96" y="45" font-family="sans-serif" font-size="13" font-weight="bold" fill="#0b1220" text-anchor="middle">1</text></svg>
"""


def trophy_glove():
    return """<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><rect width="128" height="128" rx="22" fill="#0b1220"/><rect x="42" y="34" width="44" height="60" rx="16" fill="#f2cd72" stroke="#9a7418" stroke-width="3"/><path d="M52 34 V22 M64 34 V18 M76 34 V22" stroke="#f2cd72" stroke-width="9" stroke-linecap="round"/><rect x="42" y="78" width="44" height="12" rx="4" fill="#e8b64c"/><circle cx="64" cy="58" r="10" fill="none" stroke="#9a7418" stroke-width="3"/><circle cx="64" cy="58" r="3" fill="#9a7418"/></svg>
"""


def trophy_star():
    return """<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><rect width="128" height="128" rx="22" fill="#0b1220"/><path d="M52 14 L64 34 L76 14 L84 14 L70 44 H58 L44 14 Z" fill="#c33" /><path d="M64 14 L70 30 L76 14 Z" fill="#fff" opacity="0.6"/><circle cx="64" cy="80" r="30" fill="#f2cd72" stroke="#9a7418" stroke-width="4"/><polygon points="64,60 70,74 85,74 73,83 77,97 64,88 51,97 55,83 43,74 58,74" fill="#9a7418"/></svg>
"""


def main():
    os.makedirs(LOGOS, exist_ok=True)
    os.makedirs(TROPHIES, exist_ok=True)
    clubs = list(LIGA_SUPER) + [("C%d" % i, n) for i, n in enumerate(CHAMPIONSHIP)]
    for cid, name in clubs:
        with open(os.path.join(LOGOS, cid + ".svg"), "w") as f:
            f.write(logo_svg(cid, name))
    for fname, gen in [("piala_liga.svg", trophy_cup), ("sepatu_emas.svg", trophy_boot),
                       ("sarung_emas.svg", trophy_glove), ("pemain_terbaik.svg", trophy_star)]:
        with open(os.path.join(TROPHIES, fname), "w") as f:
            f.write(gen())
    print("OK logos=%d trophies=4 -> %s" % (len(clubs), ROOT))


if __name__ == "__main__":
    main()
