"""Drop wide non-CJK characters that break monospace alignment.

Reads NotoSansMonoCJKjp-{Regular,Bold}.otf from the source directory and
writes the filtered fonts to the destination directory. A code point is
removed from every Unicode cmap subtable when both hold:
  * its East_Asian_Width is "Ambiguous" or "Neutral", and
  * its advance width is the font's full-width advance or wider.

Wide and Fullwidth characters are kept because they are intentionally wide
CJK glyphs. Glyphs, layout tables and metrics are left untouched. The cmap,
name, and the CFF top-dict family/full names change (plus
head.checkSumAdjustment).
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


def removal_targets(font):
    cmap = font.getBestCmap()
    hmtx = font["hmtx"]
    targets = set()
    for cp, glyph in cmap.items():
        advance = hmtx[glyph][0]
        width = unicodedata.east_asian_width(chr(cp))
        if width in ("A", "N") and advance >= FULL_WIDTH:
            targets.add(cp)
    return targets


def rename(font, style):
    name = font["name"]
    family = name.getDebugName(1) + " " + FAMILY_SUFFIX
    full_name = family if style == "Regular" else "%s %s" % (family, style)
    postscript = "NotoSansMonoCJKjp%s-%s" % (FAMILY_SUFFIX, style)
    for record in name.names:
        if record.nameID == 1:
            record.string = family
        elif record.nameID == 4:
            record.string = full_name
        elif record.nameID == 6:
            record.string = postscript
        elif record.nameID == 3:
            record.string = "2.004;GOOG;%s;ADOBE" % postscript

    # Keep the legacy PostScript names in the CFF top dict in sync with the
    # OpenType name table.
    if "CFF " in font:
        top = font["CFF "].cff.topDictIndex[0]
        top.FamilyName = family
        top.FullName = full_name
    return family, full_name, postscript


def assert_same_charstrings(before, after):
    a = before["CFF "].cff.topDictIndex[0].CharStrings
    b = after["CFF "].cff.topDictIndex[0].CharStrings
    assert set(a.charStrings.keys()) == set(b.charStrings.keys()), "charstring set changed"
    for gname in a.charStrings.keys():
        assert a[gname].bytecode == b[gname].bytecode, "charstring changed: %s" % gname


def filter_font(style, filename, src_dir, dst_dir):
    src = os.path.join(src_dir, filename)
    dst = os.path.join(dst_dir, "%s-%s.otf" % (filename[:-4], FAMILY_SUFFIX))
    print("\n== %s" % filename)
    print("   sha256 in :", sha256(src))

    # Keep head.modified from the source so repeated builds are identical.
    font = TTFont(src, recalcBBoxes=False, recalcTimestamp=False)
    before = set(font.getBestCmap())
    target = removal_targets(font)
    print("   cmap      :", len(before))
    print("   removing  :", len(target), "wide ambiguous/neutral")

    for subtable in font["cmap"].tables:
        if hasattr(subtable, "cmap"):
            for cp in target:
                subtable.cmap.pop(cp, None)

    family, full_name, postscript = rename(font, style)
    print("   family    :", family)
    print("   full name :", full_name)
    print("   postscript:", postscript)
    font.save(dst)

    out = TTFont(dst)
    after = set(out.getBestCmap())
    assert after == before - target, "unexpected cmap difference"
    assert not (after & target), "removed code points still present"
    if "CFF " in font:
        assert_same_charstrings(font, out)

    changed = []
    for tag in font.reader.keys():
        if tag in ("cmap", "name", "CFF "):
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
                                                   if t not in ("cmap", "name", "CFF ")))
    print("   CFF charstrings byte-identical: yes")
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
