"""Merge data/en/<id>.json timings + data/translations/it_*.json texts into <dest>/<id>.DUK.srt.

Each it_*.json maps video id -> list of strings, same length/order as data/en/<id>.json.
Usage: python build_srt.py [dest_dir]   (default: srt/)
"""
import glob, json, os, sys

base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")
dest = sys.argv[1] if len(sys.argv) > 1 else os.path.join(base, "..", "srt")


def ts(t):
    ms = int(round(t * 1000))
    return f"{ms // 3600000:02}:{ms // 60000 % 60:02}:{ms // 1000 % 60:02},{ms % 1000:03}"


def clamp_ends(segs):
    """Whisper sometimes stretches a segment over long silences: cap by reading time."""
    out = []
    for i, s in enumerate(segs):
        start, end = s["start"], s["end"]
        end = min(end, start + max(1.5, 1.0 + 0.075 * len(s["text"])))
        if i + 1 < len(segs):
            end = min(end, segs[i + 1]["start"])
        out.append((start, max(end, start + 0.5)))
    return out


def build(en, it):
    assert len(en) == len(it), "translation length mismatch"
    for s, t in zip(en, it):
        s["text"] = t
    en = [s for s in en if s["text"].strip()]  # "" = Whisper hallucination dropped by translator
    lines = []
    for n, ((a, b), s) in enumerate(zip(clamp_ends(en), en), 1):
        lines.append(f"{n}\r\n{ts(a)} --> {ts(b)}\r\n{s['text']}\r\n")
    return "\r\n".join(lines)


if __name__ == "__main__":
    assert build([{"start": 34.26, "end": 80.31, "text": "x" * 20}], ["ciao"]).startswith(
        "1\r\n00:00:34,260 --> 00:00:35,760\r\nciao")
    done = 0
    for p in sorted(glob.glob(os.path.join(base, "translations", "it_*.json"))):
        for vid, it in json.load(open(p, encoding="utf-8")).items():
            en = json.load(open(os.path.join(base, "en", vid + ".json"), encoding="utf-8"))
            try:
                srt = build(en, it)
            except AssertionError as e:
                print("SKIP", vid, e)
                continue
            ext = ".AVI" if vid == "7600" else ".DUK"  # only video shipped as .AVI
            with open(os.path.join(dest, vid + ext + ".srt"), "w", encoding="utf-8", newline="") as f:
                f.write(srt)
            done += 1
    print("srt scritti:", done)
