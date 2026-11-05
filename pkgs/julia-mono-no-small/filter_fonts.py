"""Drop small enclosed alphanumeric glyphs from JuliaMono.

Reads JuliaMono-*.ttf from the source directory and writes JuliaNoSmallMono-*.ttf
to the destination directory. A code point is removed from every Unicode
cmap subtable when its block is Enclosed Alphanumerics or Enclosed
Alphanumeric Supplement and its ink width and height are both below 0.5 em.
The removal set is computed from the Regular face and applied to every style
so the family keeps the same coverage.

Only cmap and name change (plus head.checkSumAdjustment). Glyph outlines,
layout tables and metrics are untouched. JuliaMono reserves the font name
"JuliaMono", so the derived family is called JuliaNoSmallMono.
"""

import glob
import hashlib
import os
import sys

from fontTools import unicodedata as font_unicodedata
from fontTools.pens.boundsPen import BoundsPen
from fontTools.ttLib import TTFont

FAMILY = "JuliaNoSmallMono"
REGULAR_FILE = "JuliaMono-Regular.ttf"
ENCLOSED_BLOCKS = {
    "Enclosed Alphanumerics",
    "Enclosed Alphanumeric Supplement",
}
SMALL_LIMIT = 0.5


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def small_enclosed(font):
    cmap = font.getBestCmap()
    glyphs = font.getGlyphSet()
    upm = font["head"].unitsPerEm
    targets = set()
    for cp, glyph in cmap.items():
        if font_unicodedata.block(cp) not in ENCLOSED_BLOCKS:
            continue
        pen = BoundsPen(glyphs)
        glyphs[glyph].draw(pen)
        bounds = pen.bounds
        if bounds is None:
            continue
        width = (bounds[2] - bounds[0]) / upm
        height = (bounds[3] - bounds[1]) / upm
        if width < SMALL_LIMIT and height < SMALL_LIMIT:
            targets.add(cp)
    return targets


def rename(font, suffix):
    name = font["name"]
    style = name.getDebugName(17) or name.getDebugName(2) or suffix
    family = FAMILY
    full_name = "%s %s" % (family, style)
    postscript = "%s-%s" % (family, suffix)
    for record in name.names:
        if record.nameID in (1, 16):
            record.string = family
        elif record.nameID == 2:
            record.string = style
        elif record.nameID == 4:
            record.string = full_name
        elif record.nameID == 6:
            record.string = postscript
        elif record.nameID == 17:
            record.string = style
        elif record.nameID == 3:
            record.string = "0.063;corm;%s" % postscript
    return family, style, postscript


def filter_font(src, dst, targets, suffix):
    print("\n== %s ==" % os.path.basename(src))
    print("   sha256 in :", sha256(src))

    # Keep head.modified from the source so repeated builds are identical.
    font = TTFont(src, recalcBBoxes=False, recalcTimestamp=False)
    before = set(font.getBestCmap())
    for subtable in font["cmap"].tables:
        if hasattr(subtable, "cmap"):
            for cp in targets:
                subtable.cmap.pop(cp, None)

    family, style, postscript = rename(font, suffix)
    print("   family    :", family)
    print("   style     :", style)
    print("   postscript:", postscript)
    font.save(dst)

    out = TTFont(dst)
    after = set(out.getBestCmap())
    assert after == before - targets, "unexpected cmap difference"
    assert not (after & targets), "removed code points still present"

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

    regular = TTFont(os.path.join(src_dir, REGULAR_FILE))
    targets = small_enclosed(regular)
    print("removing", len(targets), "small enclosed alphanumeric code points")
    for src in sorted(glob.glob(os.path.join(src_dir, "JuliaMono-*.ttf"))):
        suffix = os.path.basename(src)[len("JuliaMono-"):-len(".ttf")]
        dst = os.path.join(dst_dir, "%s-%s.ttf" % (FAMILY, suffix))
        filter_font(src, dst, targets, suffix)
    return 0


if __name__ == "__main__":
    sys.exit(main())
