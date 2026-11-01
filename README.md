# SOLAR MATLAB Adapter

**OptiProfiler 2.0:** See [compatibility and release boundaries](V2_COMPATIBILITY.md).

MATLAB OptiProfiler wrapper for the SOLAR black-box optimization benchmark.

This repository carries a slim SOLAR runtime under `runtime/solar/`. It keeps
the executable source, license, upstream manifest, and OptiProfiler metadata,
but intentionally excludes upstream SOLAR's large `tests/` directory.

The repository should stay lightweight. Commit the runtime source, metadata,
license, and provenance files; do not commit upstream `.git`, upstream `tests/`,
`runtime/solar/bin/solar`, `runtime/solar/bin/solar.exe`, or
`runtime/solar/src/*.o`.

## OptiProfiler Setup

The setup and registry workflow below belongs to OptiProfiler 2.0, which the
website describes only once it is released. Ordinary OptiProfiler users should
start from the core repository and let its locked setup install this adapter:

```matlab
setup(struct( ...
    'install_matcutest', false, ...
    'install_solar', true));
```

The adapter is stored below
`prefdir/optiprofiler/problem_libraries/solar` by default. A caller may choose
another writable parent with the core setup option `problem_library_root`.
After setup, use the public name directly:

```matlab
options.plibs = {'solar'};
scores = benchmark(solvers, options);

library = resolveProblemLibrary('solar');
```

To update a setup-managed adapter, update the OptiProfiler core and rerun setup.
A clean checkout is aligned to the commit in `matlab_problem_libraries.lock`;
setup does not overwrite a dirty checkout. Do not run `git pull`
unconditionally in the setup-managed directory.

Detach the provider without deleting its files:

```matlab
unregisterProblemLibrary('solar');
```

This preserves the adapter checkout, vendored runtime source, compiled binary,
build artifacts, caches, and user data. `install_solar=false` only skips SOLAR
during that setup run; it does not unregister or delete anything. Likewise,
`setup uninstall` removes OptiProfiler-managed MATLAB paths but preserves the
registry and external files. There is deliberately no destructive setup
option.

## Build Runtime

```matlab
[~, ~] = mkdir(fullfile('runtime', 'solar', 'bin'));
system('make -C runtime/solar/src')
```

The makefile links into `runtime/solar/bin`, which a clean checkout does not
contain, so create it first (`mkdir -p runtime/solar/bin` in a shell).

Manual `make` is intended for adapter development or troubleshooting. Ordinary
OptiProfiler users do not need to run it before selecting SOLAR: the wrapper
builds the binary on first use when it is missing.

The binary is generated at `runtime/solar/bin/solar` and is ignored by git.
On Windows, the binary is generated at `runtime/solar/bin/solar.exe`.
First build is protected by a local directory lock, so parallel workers do not
try to compile and link the same runtime at the same time. If a build is killed
outright, the lock directory `runtime/solar/.build.lock.d` stays behind; later
loads wait at most 600 s and then report it. Delete it once no build is running.

The build requires `make` and a C++ compiler compatible with upstream SOLAR.
On Linux and macOS this is usually the system `make` plus `g++`/Clang. On
Windows, use MSYS2/MinGW or an equivalent environment that exposes `make` and
`g++` on the MATLAB process `PATH`.

## Automation

`scripts/collect_info.m` regenerates `probinfo_matlab.csv` and
`probinfo_matlab.mat` by loading each enabled SOLAR problem through
`solar_load` and reading the resulting OptiProfiler `Problem` fields.
The vendored metadata is still needed to construct each problem, but the
selection index is derived from the wrapper contract that users actually call.
The MAT-file header is normalized so repeated generation does not create
timestamp-only diffs. The CI workflow checks both metadata files, runs a MATLAB
smoke test, and verifies that local build artifacts stay ignored.

`Prepare SOLAR Runtime Candidate` is a manual review tool. It requires an exact
adapter revision and exact upstream SOLAR commit, exports a slim runtime,
regenerates the MATLAB metadata, runs the smoke test, and uploads a candidate
archive. It never commits the candidate. `Collect Info` is also manual and only
uploads regenerated metadata.

The daily random smoke runs at 07:00 Beijing time. It records a reproducible
seed and evaluates two metadata-reviewed fast problems at their initial points.
Numerical-library thread counts are capped at two.

## Usage

```matlab
names = solar_select(struct('ptype', 'n', 'maxdim', 20));
problem = solar_load(names{1});
problem.fun(problem.x0)
```

## Public API

The public problem-library name is `solar`. User-facing code should normally
use the following entry points:

- `solar_load(problem_name)` loads one enabled scalar SOLAR problem as an
  OptiProfiler `Problem` instance.
- `solar_select(options)` returns enabled scalar SOLAR problem names satisfying
  OptiProfiler-style selection criteria.
- `solar_collect_info()` returns the committed problem-information table used
  by `solar_select`.

This repository also keeps `solar_matlab_load`, `solar_matlab_select`, and
`solar_matlab_collect_info` as MATLAB-specific implementation and compatibility
entry points. They are not the preferred names for user code.

In OptiProfiler, use this adapter as the problem library `solar`, for example
`options.plibs = {'solar'}`. The GitHub source repository name is
language-specific, but the public problem-library name is `solar`.

SOLAR 8 and 9 are multiobjective and are not returned by the first scalar
OptiProfiler selector. SOLAR 11 is disabled for now because upstream SOLAR
v1.0.8 returns an empty output at the documented initial point.

## License and Provenance

The MATLAB adapter, generated metadata, maintenance scripts, tests and wrapper
documentation are licensed under the [BSD 3-Clause License](LICENSE). That license
covers only these OptiProfiler-authored files.

The vendored SOLAR files under `runtime/solar/` keep their own licenses.
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) is the component inventory. The
runtime manifest records the exact upstream SOLAR commit. The upstream repository
provides an LGPL-2.1 license file, while every SOLAR C++ source file declares
LGPL version 3 or later. This repository preserves both, and adds the official
LGPL-3.0 and GPL-3.0 texts in `licenses/`, because LGPL version 3 supplements GPL
version 3. Nothing is relicensed. Downstream distributions should keep the
notices, license texts, source notices, manifest and upstream URL together.

## Runtime Expectations

SOLAR problems call an external C++ solar-plant simulator. Some instances are
substantially more expensive than ordinary algebraic test problems: a single
objective or constraint evaluation can keep one CPU core busy for many seconds
or longer. In local OptiProfiler tests, `SOLAR5_MAXCOMP_HTF1` has been the
clearest slow case. `SOLAR3_MINCOST_C1` and `SOLAR4_MINCOST_C2` can also be
noticeably slower than the small storage/receiver instances, depending on the
trial point and solver behavior.

Solver choice can multiply this cost. MATLAB `fmincon` with finite
differences, or any solver that estimates derivatives internally, may call the
SOLAR executable many times per iteration. A run may appear quiet while the
simulator is still using CPU. For smoke tests, start with `SOLAR6_MINCOST_TS`
or `SOLAR10_MINCOST_UNCONSTRAINED`, use `n_jobs=1`, and keep
`max_eval_factor` small.

## Integer Variables

Several scalar SOLAR instances include integer or categorical variables. Before
calling the SOLAR executable, this wrapper rounds every `I` coordinate to the
nearest integer and clips it to the integer bounds recorded in the metadata.
This avoids upstream SOLAR rejecting noninteger trial points generated by
continuous solvers.

This is a wrapper-level mixed-integer handling rule, not a claim that those
instances are native continuous problems. For a strictly continuous DFO
benchmark, use the pure-continuous SOLAR instances, currently SOLAR 6 and
SOLAR 10, or report the rounding policy explicitly.

## Evaluation Accounting

SOLAR returns objective and constraint values from one executable call. The
MATLAB wrapper may cache that raw executable result inside `solar_load`; it does
not call OptiProfiler-visible `cub` from `fun`, or `fun` from `cub`. This
preserves OptiProfiler's separate objective and constraint evaluation histories.

SOLAR may return a nonzero process status for a simulation point while still
printing a complete numeric output vector, usually with `1e20` penalty values.
The wrapper treats a complete numeric vector as the SOLAR evaluation result and
raises an execution error only when the process fails without a complete output
vector.
