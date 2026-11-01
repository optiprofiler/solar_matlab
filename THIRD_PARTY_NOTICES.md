# Third-Party Notices

This repository combines the OptiProfiler MATLAB wrapper with a slim snapshot of
the SOLAR simulator. The components keep separate terms. Nothing here relicenses
the native source, and no license is inferred for one component from another.

## Component inventory

| Component | Paths | Terms | License text |
| --- | --- | --- | --- |
| SOLAR C++ sources | `runtime/solar/src/*.cpp`, `runtime/solar/src/*.hpp` | LGPL-3.0-or-later, as stated by the notice in every file | `licenses/LGPL-3.0.txt`, `licenses/GPL-3.0.txt` |
| Other upstream files without a file-level notice | `runtime/solar/src/makefile`, `runtime/solar/README.upstream.md` | LGPL-2.1-only, recorded conservatively from the upstream repository's `LICENSE` file | `runtime/solar/LICENSE` |
| OptiProfiler wrapper, metadata, documentation, scripts, tests and workflows | Root `*.m` and `*.md`, `probinfo_matlab.*`, `runtime/solar/manifest.json`, `runtime/solar/README.md`, `runtime/solar/metadata/`, `scripts/`, `tests/`, `.github/`, `.gitattributes`, `.gitignore` | BSD-3-Clause | `LICENSE` |

## SOLAR runtime

The slim runtime is derived from [bbopt/solar](https://github.com/bbopt/solar)
at commit `dda8fd7f98d4392aa07b3e3056888624a00712a0`, as recorded in
`runtime/solar/manifest.json`. Its upstream directory `tests/` is not included.

Every distributed `runtime/solar/src/*.cpp` and `*.hpp` file carries an explicit
upstream notice granting use under the GNU Lesser General Public License,
version 3 or later. Those notices are preserved without modification. Because
LGPL version 3 supplements GPL version 3, both official texts are included in
`licenses/`.

The upstream repository's own `LICENSE` file is LGPL-2.1, and it is preserved
verbatim at `runtime/solar/LICENSE`. The upstream root license and the
file-specific notices name different LGPL versions. This repository does not
reinterpret or remove either of them; it preserves both and reports their
file-level scope conservatively.

The snapshot contains small portability changes to the copied runtime, including
a `std::isnan` compatibility fix and makefile portability settings. Modified
upstream files retain their upstream license category.

Keep these notices, the license texts, the source notices, the manifest and the
upstream URL together in every redistribution.

## OptiProfiler wrapper

The MATLAB wrapper, generated metadata, documentation, maintenance scripts, tests
and workflows listed above are independent OptiProfiler work, licensed under the
BSD 3-Clause License in `LICENSE`. That license covers only these files and does
not cover the SOLAR material above. The LGPL and GPL texts above govern the SOLAR
material only and do not apply to the wrapper by virtue of being stored here.
