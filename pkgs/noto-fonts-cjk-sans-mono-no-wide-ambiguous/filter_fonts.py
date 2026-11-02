"""Drop East-Asian-Ambiguous characters that the font draws at full width.

Reads NotoSansMonoCJKjp-{Regular,Bold}.otf from the source directory and
writes the filtered fonts to the destination directory. A code point is
removed from every Unicode cmap subtable when both hold:
  * its East_Asian_Width is "Ambiguous" (UAX #11), and
  * its advance width equals the font's full-width advance.

Glyphs, layout tables and metrics are left untouched, so the only tables
that change are cmap and name (plus head.checkSumAdjustment).
"""

import hashlib
import os
import sys
import unicodedata

from fontTools import version as fonttools_version
from fontTools.ttLib import TTFont

FULL_WIDTH = 1000
FAMILY_SUFFIX = "NoWideAmbiguous"
JOBS = [
    ("Regular", "NotoSansMonoCJKjp-Regular.otf"),
    ("Bold", "NotoSansMonoCJKjp-Bold.otf"),
]


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def full_width_ambiguous(font):
    cmap = font.getBestCmap()
    hmtx = font["hmtx"]
    return {
        cp
        for cp, glyph in cmap.items()
        if unicodedata.east_asian_width(chr(cp)) == "A"
        and hmtx[glyph][0] == FULL_WIDTH
    }


def rename(font, style):
    family = font["name"].getDebugName(1) + " " + FAMILY_SUFFIX
    postscript = "NotoSansMonoCJKjp%s-%s" % (FAMILY_SUFFIX, style)
    name = font["name"]
    for record in name.names:
        if record.nameID in (1, 4):
            record.string = family
        elif record.nameID == 6:
            record.string = postscript
        elif record.nameID == 3:
            record.string = "2.004;GOOG;%s;ADOBE" % postscript
    return family, postscript


def filter_font(style, filename, src_dir, dst_dir):
    src = os.path.join(src_dir, filename)
    dst = os.path.join(dst_dir, "%s-%s.otf" % (filename[:-4], FAMILY_SUFFIX))
    print("\n== %s" % filename)
    print("   sha256 in :", sha256(src))

    # Keep head.modified from the source so repeated builds are identical.
    font = TTFont(src, recalcBBoxes=False, recalcTimestamp=False)
    before = set(font.getBestCmap())
    target = full_width_ambiguous(font)
    print("   cmap      :", len(before))
    print("   removing  :", len(target), "full-width ambiguous")

    for subtable in font["cmap"].tables:
        if hasattr(subtable, "cmap"):
            for cp in target:
                subtable.cmap.pop(cp, None)

    family, postscript = rename(font, style)
    print("   family    :", family)
    print("   postscript:", postscript)
    font.save(dst)

    out = TTFont(dst)
    after = set(out.getBestCmap())
    assert after == before - target, "unexpected cmap difference"
    assert not (after & target), "removed code points still present"

    changed = []
    for tag in font.reader.keys():
        if tag in ("cmap", "name"):
            continue
        if tag == "head":
            # checkSumAdjustment is recomputed for the new file by definition.
            diff = [k for k in font["head"].__dict__
                    if k != "checkSumAdjustment"
                    and getattr(font["head"], k) != getattr(out["head"], k)]
            if diff:
                changed.append("head:%s" % diff)
        elif font.getTableData(tag) != out.getTableData(tag):
            changed.append(tag)
    assert not changed, "unexpected table changes: %s" % changed

    print("   cmap out  :", len(after), "(lost %d)" % (len(before) - len(after)))
    print("   other tables byte-identical:", sorted(t for t in font.reader.keys()
                                                   if t not in ("cmap", "name")))
    print("   sha256 out:", sha256(dst))
    print("   written   :", dst)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: %s SRC_DIR DST_DIR" % sys.argv[0])
    src_dir, dst_dir = sys.argv[1], sys.argv[2]
    print("fontTools", fonttools_version)
    for style, filename in JOBS:
        filter_font(style, filename, src_dir, dst_dir)
    return 0


if __name__ == "__main__":
    sys.exit(main())
