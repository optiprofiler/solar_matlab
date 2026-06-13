repo_dir = fileparts(fileparts(mfilename('fullpath')));
restoredefaultpath;
addpath(repo_dir);

local_op_src = fullfile(fileparts(fileparts(repo_dir)), ...
    'optiprofiler', 'matlab', 'optiprofiler', 'src');
ci_op_src = fullfile(repo_dir, 'optiprofiler', ...
    'matlab', 'optiprofiler', 'src');
if exist(ci_op_src, 'dir') == 7
    addpath(ci_op_src);
elseif exist(local_op_src, 'dir') == 7
    addpath(local_op_src);
else
    error('SOLAR:SmokeTest', 'Could not find OptiProfiler MATLAB source path.');
end

names = solar_matlab_select(struct('ptype', 'n', 'maxdim', 10));
assert(ismember('SOLAR1_MAXNRG_H1', names));
assert(ismember('SOLAR6_MINCOST_TS', names));
assert(~ismember('SOLAR11_MINCOST_CH', names));
assert(isequal(names, solar_select(struct('ptype', 'n', 'maxdim', 10))));

all_names = solar_matlab_select(struct('ptype', 'bn', 'maxdim', 100, ...
    'maxb', 100, 'maxnlcon', 100, 'maxcon', 100));
expected_enabled = {'SOLAR1_MAXNRG_H1', 'SOLAR2_MINSURF_H1', ...
    'SOLAR3_MINCOST_C1', 'SOLAR4_MINCOST_C2', 'SOLAR5_MAXCOMP_HTF1', ...
    'SOLAR6_MINCOST_TS', 'SOLAR7_MAXEFF_RE', ...
    'SOLAR10_MINCOST_UNCONSTRAINED'};
assert(isequal(all_names, expected_enabled));
assert(~ismember('SOLAR8_MAXHF_MINCOST', all_names));
assert(~ismember('SOLAR9_MAXNRG_MINPAR', all_names));

p = solar_matlab_load('SOLAR1_MAXNRG_H1');
assert(strcmp(p.name, 'SOLAR1_MAXNRG_H1'));
assert(p.n == 9);
assert(p.m_nonlinear_ub == 5);
fx = p.fun(p.x0);
assert(abs(fx - (-122505.5978)) < 1e-3);
cubx = p.cub(p.x0);
assert(numel(cubx) == 5);
x = p.x0;
x(6) = 250.5;
assert(isfinite(p.fun(x)));
assert(~any(isnan(p.cub(x))));
assert(solar_load('SOLAR10_MINCOST_UNCONSTRAINED').n == 5);

disp('solar_matlab smoke ok');
