function problem = solar_matlab_load(problem_name)
%SOLAR_MATLAB_LOAD loads one SOLAR problem as an OptiProfiler Problem.
%
%   PROBLEM = SOLAR_MATLAB_LOAD(PROBLEM_NAME) is the MATLAB-specific
%   implementation used by the public entry point `solar_load`. Users should
%   normally call `solar_load`, whose name matches the OptiProfiler problem
%   library name `solar`.
%
%   The returned Problem contains the same fields exposed by SOLAR_LOAD:
%   objective function, initial point, bounds, and nonlinear inequality
%   constraints when the SOLAR instance has constraints. This wrapper does not
%   expose derivative functions.
%
%   See also SOLAR_LOAD, SOLAR_SELECT, SOLAR_COLLECT_INFO.

    meta = find_solar_problem(problem_name);
    if ~meta.enabled
        error('SOLAR:DisabledProblem', 'SOLAR problem is disabled: %s', problem_name);
    end

    state = solar_state(meta);
    p_struct.name = meta.name;
    p_struct.x0 = meta.x0;
    p_struct.xl = meta.xl;
    p_struct.xu = meta.xu;
    p_struct.fun = @(x) solar_fun(state, x);
    if meta.m_constraints > 0
        p_struct.cub = @(x) solar_cub(state, x);
    end
    problem = Problem(p_struct);
end

function meta = find_solar_problem(problem_name)
    problems = solar_metadata();
    problem_name = char(problem_name);
    for i_problem = 1:numel(problems)
        if strcmp(problems(i_problem).name, problem_name)
            meta = problems(i_problem);
            return;
        end
    end
    error('SOLAR:UnknownProblem', 'Unknown SOLAR problem: %s', problem_name);
end

function state = solar_state(meta)
    state.meta = meta;
    state.executable = ensure_solar_executable();
end

function fx = solar_fun(state, x)
    [objectives, ~] = solar_eval(state, x);
    fx = objectives(1);
end

function cubx = solar_cub(state, x)
    x = x(:);
    if is_problem_size_probe()
        cubx = NaN(state.meta.m_constraints, 1);
        return;
    end
    [~, constraints] = solar_eval(state, x);
    cubx = constraints(:);
end

function [objectives, constraints] = solar_eval(state, x)
    x = prepare_solar_input(state.meta, x);
    cache_key = solar_cache_key(state, x);
    persistent last_key last_objectives last_constraints
    if ~isempty(last_key) && strcmp(last_key, cache_key)
        objectives = last_objectives;
        constraints = last_constraints;
        return;
    end

    input_file = [tempname, '.txt'];
    cleanup = onCleanup(@() delete_if_exists(input_file));
    write_point(input_file, x);
    command = sprintf('"%s" %d "%s" -seed=0 -fid=1.0 -rep=1', state.executable, state.meta.pb_id, input_file);
    [status, stdout] = solar_system(command);

    values = parse_solar_stdout(stdout);
    expected = state.meta.m_objectives + state.meta.m_constraints;
    if numel(values) ~= expected
        if status ~= 0
            error('SOLAR:ExecutionFailed', 'SOLAR failed with status %d and returned %d numeric values, expected %d: %s', status, numel(values), expected, stdout);
        end
        error('SOLAR:UnexpectedOutputShape', 'SOLAR returned %d numeric values, expected %d.', numel(values), expected);
    end

    objectives = values(1:state.meta.m_objectives);
    constraints = values(state.meta.m_objectives + 1:end);
    last_key = cache_key;
    last_objectives = objectives;
    last_constraints = constraints;
end

function key = solar_cache_key(state, x)
    key = sprintf('%s|%d|%s', state.executable, state.meta.pb_id, format_point_key(x));
end

function key = format_point_key(x)
    pieces = cell(numel(x), 1);
    for i = 1:numel(x)
        pieces{i} = sprintf('%.17g', x(i));
    end
    key = strjoin(pieces, ',');
end

function x = prepare_solar_input(meta, x)
    x = double(x(:));
    if numel(x) ~= meta.n
        error('SOLAR:WrongInputDimension', 'SOLAR input has dimension %d, expected %d.', numel(x), meta.n);
    end
    for i = 1:numel(x)
        if ~strcmp(meta.input_type{i}, 'I') || ~isfinite(x(i))
            continue;
        end
        value = floor(x(i) + 0.5);
        if isfinite(meta.xl(i))
            value = max(value, ceil(meta.xl(i)));
        end
        if isfinite(meta.xu(i))
            value = min(value, floor(meta.xu(i)));
        end
        x(i) = value;
    end
end

function executable = ensure_solar_executable()
    root = fileparts(mfilename('fullpath'));
    executable = fullfile(root, 'runtime', 'solar', 'bin', solar_executable_name());
    if exist(executable, 'file') == 2
        return;
    end

    runtime_dir = fullfile(root, 'runtime', 'solar');
    lock_dir = fullfile(runtime_dir, '.build.lock.d');
    cleanup_lock = acquire_build_lock(lock_dir); %#ok<NASGU>
    if exist(executable, 'file') == 2
        return;
    end

    bin_dir = fileparts(executable);
    if exist(bin_dir, 'dir') ~= 7
        mkdir(bin_dir);
    end
    source_dir = fullfile(runtime_dir, 'src');
    make_command = sprintf('make -C "%s"%s', source_dir, solar_make_exeext_arg());
    [status, output] = solar_system(make_command);
    if status ~= 0 || exist(executable, 'file') ~= 2
        error('SOLAR:BuildFailed', 'Failed to build SOLAR executable: %s', output);
    end
end

function name = solar_executable_name()
    if ispc
        name = 'solar.exe';
    else
        name = 'solar';
    end
end

function arg = solar_make_exeext_arg()
    if ispc
        arg = ' EXEEXT=.exe LIBS=-lm';
    else
        arg = '';
    end
end

function [status, output] = solar_system(command)
    if isunix
        command = ['env -u LD_LIBRARY_PATH -u DYLD_LIBRARY_PATH -u DYLD_FRAMEWORK_PATH ', command];
    end
    [status, output] = system(command);
end

function cleanup_lock = acquire_build_lock(lock_dir)
    timeout_sec = 600;
    started = tic;
    while true
        [status, message] = system(sprintf('mkdir "%s"', lock_dir));
        if status == 0
            cleanup_lock = onCleanup(@() release_build_lock(lock_dir));
            return;
        end
        if toc(started) > timeout_sec
            error('SOLAR:BuildLockTimeout', 'Timed out waiting for SOLAR build lock: %s', strtrim(message));
        end
        pause(0.1);
    end
end

function release_build_lock(lock_dir)
    if exist(lock_dir, 'dir') == 7
        rmdir(lock_dir);
    end
end

function write_point(path, x)
    fid = fopen(path, 'w');
    if fid < 0
        error('SOLAR:InputFileOpenFailed', 'Could not open temporary SOLAR input file.');
    end
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%.17g', x(1));
    for i = 2:numel(x)
        fprintf(fid, ' %.17g', x(i));
    end
    fprintf(fid, '\n');
end

function values = parse_solar_stdout(stdout)
    lines = regexp(stdout, '\r?\n', 'split');
    values = [];
    for i = numel(lines):-1:1
        line = strtrim(lines{i});
        if isempty(line)
            continue;
        end
        pieces = regexp(line, '\s+', 'split');
        candidate = str2double(pieces);
        if all(~isnan(candidate))
            values = candidate(:);
            return;
        end
    end
    error('SOLAR:ParseFailed', 'SOLAR output could not be parsed: %s', stdout);
end

function delete_if_exists(path)
    if exist(path, 'file') == 2
        delete(path);
    end
end

function tf = is_problem_size_probe()
    stack = dbstack();
    tf = false;
    for i = 1:numel(stack)
        if strcmp(stack(i).name, 'Problem.get.m_nonlinear_ub')
            tf = true;
            return;
        end
    end
end
