repo_dir = fileparts(fileparts(mfilename('fullpath')));
op_root = fileparts(fileparts(repo_dir));
restoredefaultpath;
addpath(repo_dir);
addpath(fullfile(op_root, 'optiprofiler', 'matlab', 'optiprofiler', 'src'));

names = solar_select(struct('ptype', 'n', 'maxdim', 10));
assert(ismember('SOLAR1_MAXNRG_H1', names));
assert(ismember('SOLAR6_MINCOST_TS', names));
assert(~ismember('SOLAR11_MINCOST_CH', names));

p = solar_load('SOLAR1_MAXNRG_H1');
assert(strcmp(p.name, 'SOLAR1_MAXNRG_H1'));
assert(p.n == 9);
assert(p.m_nonlinear_ub == 5);
fx = p.fun(p.x0);
assert(abs(fx - (-122505.5978)) < 1e-8);
cubx = p.cub(p.x0);
assert(numel(cubx) == 5);

disp('solar_matlab smoke ok');
