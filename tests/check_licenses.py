"""Check the SOLAR license inventory against the files in this repository."""

from hashlib import sha256
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
TEXTS = {
    "licenses/GPL-3.0.txt": "3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986",
    "licenses/LGPL-3.0.txt": "e3a994d82e644b03a792a930f574002658412f62407f5fee083f2555c5f23118",
    "runtime/solar/LICENSE": "20c17d8b8c48a600800dfd14f95d5cb9ff47066a9641ddeab48dc54aec96e331",
}
HEADER = re.compile(
    r"under the terms of the GNU Lesser General Public License as published by\s*\*/\s*"
    r"/\*\s*the Free Software Foundation, either version 3 of the License, or \(at your"
)
UNHEADED_UPSTREAM = {"runtime/solar/src/makefile", "runtime/solar/README.upstream.md"}


def main():
    for name, expected in TEXTS.items():
        actual = sha256((ROOT / name).read_bytes()).hexdigest()
        if actual != expected:
            raise AssertionError(f"{name}: unexpected text {actual}")
    sources = sorted((ROOT / "runtime/solar/src").glob("*.[ch]pp"))
    if not sources:
        raise AssertionError("No SOLAR sources found.")
    for path in sources:
        if not HEADER.search(path.read_text(encoding="utf-8", errors="replace")):
            raise AssertionError(f"{path.name}: expected an LGPL-3.0-or-later notice")
    notice = (ROOT / "THIRD_PARTY_NOTICES.md").read_text(encoding="utf-8")
    for marker in (*TEXTS, *UNHEADED_UPSTREAM, "LGPL-3.0-or-later", "LGPL-2.1-only",
                   "dda8fd7f98d4392aa07b3e3056888624a00712a0"):
        if marker not in notice:
            raise AssertionError(f"THIRD_PARTY_NOTICES.md does not mention {marker}")
    print(f"Checked {len(TEXTS)} license texts and {len(sources)} source notices.")


if __name__ == "__main__":
    main()
