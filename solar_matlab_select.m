function problem_names = solar_matlab_select(options)
%SOLAR_MATLAB_SELECT selects SOLAR problems satisfying OptiProfiler-style criteria.

    if nargin < 1 || isempty(options)
        options = struct();
    end
    if ~isfield(options, 'ptype')
        options.ptype = 'ubln';
    end
    if ~isfield(options, 'mindim')
        options.mindim = 1;
    end
    if ~isfield(options, 'maxdim')
        options.maxdim = Inf;
    end
    if ~isfield(options, 'minb')
        options.minb = 0;
    end
    if ~isfield(options, 'maxb')
        options.maxb = Inf;
    end
    if ~isfield(options, 'minlcon')
        options.minlcon = 0;
    end
    if ~isfield(options, 'maxlcon')
        options.maxlcon = Inf;
    end
    if ~isfield(options, 'minnlcon')
        options.minnlcon = 0;
    end
    if ~isfield(options, 'maxnlcon')
        options.maxnlcon = Inf;
    end
    if ~isfield(options, 'mincon')
        options.mincon = 0;
    end
    if ~isfield(options, 'maxcon')
        options.maxcon = Inf;
    end
    if ~isfield(options, 'excludelist')
        options.excludelist = {};
    end

    problems = solar_metadata();
    problem_names = {};
    for i_problem = 1:numel(problems)
        problem = problems(i_problem);
        if ~problem.enabled
            continue;
        end
        row = solar_row(problem);
        if ismember(row.name, options.excludelist)
            continue;
        end
        if ~contains(options.ptype, row.ptype)
            continue;
        end
        if row.dim < options.mindim || row.dim > options.maxdim
            continue;
        end
        if row.mb < options.minb || row.mb > options.maxb
            continue;
        end
        if row.mlcon < options.minlcon || row.mlcon > options.maxlcon
            continue;
        end
        if row.mnlcon < options.minnlcon || row.mnlcon > options.maxnlcon
            continue;
        end
        if row.mcon < options.mincon || row.mcon > options.maxcon
            continue;
        end
        problem_names{end + 1} = row.name; %#ok<AGROW>
    end
end

function row = solar_row(problem)
    row.name = problem.name;
    row.dim = problem.n;
    row.mb = sum(isfinite(problem.xl)) + sum(isfinite(problem.xu));
    row.mlcon = 0;
    row.mnlcon = problem.m_constraints;
    row.mcon = problem.m_constraints;
    if problem.m_constraints > 0
        row.ptype = 'n';
    elseif row.mb > 0
        row.ptype = 'b';
    else
        row.ptype = 'u';
    end
end
