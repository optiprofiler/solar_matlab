# SOLAR MATLAB Adapter

MATLAB OptiProfiler wrapper for the SOLAR black-box optimization benchmark.

This repository carries a slim SOLAR runtime under `runtime/solar/`. It keeps
the executable source, license, upstream manifest, and OptiProfiler metadata,
but intentionally excludes upstream SOLAR's large `tests/` directory.

The repository should stay lightweight. Commit the runtime source, metadata,
license, and provenance files; do not commit upstream `.git`, upstream `tests/`,
`runtime/solar/bin/solar`, or `runtime/solar/src/*.o`.

## Build Runtime

```matlab
system('make -C runtime/solar/src')
```

The binary is generated at `runtime/solar/bin/solar` and is ignored by git.

## Usage

```matlab
names = solar_matlab_select(struct('ptype', 'n', 'maxdim', 20));
problem = solar_matlab_load(names{1});
problem.fun(problem.x0)
```

For convenience, `solar_load`, `solar_select`, and `solar_collect_info` are also
available as aliases. The canonical OptiProfiler entry points are
`solar_matlab_load.m` and `solar_matlab_select.m`, so the repository can be used
as `plib="solar_matlab"` without relying on shorter alias names.

SOLAR 8 and 9 are multiobjective and are not returned by the first scalar
OptiProfiler selector. SOLAR 11 is disabled for now because upstream SOLAR
v1.0.8 returns an empty output at the documented initial point.

## Evaluation Accounting

SOLAR returns objective and constraint values from one executable call. The
MATLAB wrapper keeps that joint-oracle detail inside `solar_load`; it does not
call OptiProfiler-visible `cub` from `fun`, or `fun` from `cub`. This preserves
OptiProfiler's separate objective and constraint evaluation histories.
