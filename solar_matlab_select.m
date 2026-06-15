function problem_names = solar_matlab_select(options)
%SOLAR_MATLAB_SELECT selects SOLAR problems satisfying OptiProfiler-style criteria.
%
%   PROBLEM_NAMES = SOLAR_MATLAB_SELECT(OPTIONS) is the MATLAB-specific
%   implementation used by the public entry point `solar_select`. Users should
%   normally call `solar_select`, whose name matches the OptiProfiler problem
%   library name `solar`.
%
%   The selection table is read from `probinfo_matlab.csv`, which is generated
%   from actual `solar_load` results. The vendored metadata is used only to
%   filter currently enabled problems.
%
%   OPTIONS accepts the same fields as SOLAR_SELECT: ptype, mindim, maxdim,
%   minb, maxb, minlcon, maxlcon, minnlcon, maxnlcon, mincon, maxcon, and
%   excludelist.
%
%   See also SOLAR_SELECT, SOLAR_LOAD, SOLAR_COLLECT_INFO.

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
    enabled_names = {problems([problems.enabled]).name};
    rows = readtable(fullfile(fileparts(mfilename('fullpath')), 'probinfo_matlab.csv'), ...
        'TextType', 'char');
    problem_names = {};
    for i_problem = 1:height(rows)
        row.name = table_value(rows.name, i_problem);
        row.ptype = table_value(rows.ptype, i_problem);
        row.dim = rows.dim(i_problem);
        row.mb = rows.mb(i_problem);
        row.mlcon = rows.mlcon(i_problem);
        row.mnlcon = rows.mnlcon(i_problem);
        row.mcon = rows.mcon(i_problem);
        if ~ismember(row.name, enabled_names)
            continue;
        end
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

function value = table_value(column, index)
    if iscell(column)
        value = column{index};
    elseif isstring(column)
        value = char(column(index));
    else
        value = char(column(index, :));
    end
end
