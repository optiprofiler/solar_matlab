repo_dir = fileparts(fileparts(mfilename('fullpath')));
restoredefaultpath;
addpath(repo_dir);

local_op_src = fullfile(fileparts(fileparts(repo_dir)), ...
    'optiprofiler', 'matlab', 'optiprofiler', 'src');
ci_op_src = fullfile(repo_dir, 'optiprofiler', 'matlab', 'optiprofiler', 'src');
if exist(ci_op_src, 'dir') == 7
    addpath(ci_op_src);
elseif exist(local_op_src, 'dir') == 7
    addpath(local_op_src);
else
    error('SOLAR:DailySmoke', 'Could not find OptiProfiler MATLAB source path.');
end

seed_text = getenv('OP_RANDOM_SEED');
if isempty(seed_text)
    seed_text = datestr(datetime('today'), 'yyyymmdd');
end
seed = str2double(seed_text);
if isnan(seed)
    error('SOLAR:DailySmoke', 'OP_RANDOM_SEED must be numeric.');
end
rng(seed);

fast_names = {'SOLAR1_MAXNRG_H1', 'SOLAR2_MINSURF_H1', ...
    'SOLAR6_MINCOST_TS', 'SOLAR7_MAXEFF_RE', ...
    'SOLAR10_MINCOST_UNCONSTRAINED'};
chosen = fast_names(randperm(numel(fast_names), 2));
fprintf('SOLAR MATLAB random sample seed=%d: %s, %s\n', ...
    seed, chosen{1}, chosen{2});

for i = 1:numel(chosen)
    started = tic;
    problem = solar_load(chosen{i});
    objective = problem.fun(problem.x0);
    cub = problem.cub(problem.x0);
    ceq = problem.ceq(problem.x0);
    values = [objective; cub(:); ceq(:)];
    assert(all(isfinite(values) | isnan(values)));
    fprintf('%s: f(x0)=%.16g, elapsed=%.3fs\n', ...
        chosen{i}, objective, toc(started));
end

disp('solar_matlab daily random smoke ok');
