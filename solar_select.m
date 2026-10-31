function problem_names = solar_select(options)
%SOLAR_SELECT selects SOLAR problems that satisfy given criteria.
%
%   PROBLEM_NAMES = SOLAR_SELECT(OPTIONS) returns the names of enabled scalar
%   SOLAR problems that satisfy the criteria in OPTIONS as a cell array
%   PROBLEM_NAMES. More details about the upstream SOLAR benchmark can be found
%   at <https://github.com/bbopt/solar>.
%
%   OPTIONS is a struct with the following fields:
%
%       - ptype: the type of the problems to be selected. It should be a string
%         or char consisting of any combination of 'u' (unconstrained), 'b'
%         (bound constrained), 'l' (linearly constrained), and 'n' (nonlinearly
%         constrained), such as 'b', 'ul', 'ubn'. Default is 'ubln'.
%       - mindim: the minimum dimension of the problems to be selected. Default
%         is 1.
%       - maxdim: the maximum dimension of the problems to be selected. Default
%         is Inf.
%       - minb: the minimum number of bound constraints of the problems to be
%         selected. Default is 0.
%       - maxb: the maximum number of bound constraints of the problems to be
%         selected. Default is Inf.
%       - minlcon: the minimum number of linear constraints of the problems to
%         be selected. Default is 0.
%       - maxlcon: the maximum number of linear constraints of the problems to
%         be selected. Default is Inf.
%       - minnlcon: the minimum number of nonlinear constraints of the problems
%         to be selected. Default is 0.
%       - maxnlcon: the maximum number of nonlinear constraints of the problems
%         to be selected. Default is Inf.
%       - mincon: the minimum number of linear and nonlinear constraints of the
%         problems to be selected. Default is 0.
%       - maxcon: the maximum number of linear and nonlinear constraints of the
%         problems to be selected. Default is Inf.
%       - excludelist: the list of problems to be excluded. Default is not to
%         exclude any problem.
%
%   Two things to note:
%
%       1. This selector currently returns scalar SOLAR problems only. SOLAR 8
%          and 9 are multiobjective and are not returned. SOLAR 11 is disabled
%          because the current upstream snapshot returns an empty output at the
%          documented initial point.
%       2. Several scalar SOLAR instances include integer or categorical
%          variables. The wrapper rounds every `I` coordinate before calling the
%          SOLAR executable. This is a wrapper-level mixed-integer handling
%          rule, not a claim that those instances are native continuous
%          problems.
%
%   The SOLAR MATLAB adapter vendors a slim SOLAR runtime. Its C++ sources declare
%   LGPL-3.0-or-later, and the upstream makefile and README follow the LGPL-2.1
%   license file of the upstream repository. See THIRD_PARTY_NOTICES.md for the
%   complete inventory. The runtime keeps its upstream license, README, and
%   manifest under `runtime/solar/`. Some SOLAR problems call a comparatively
%   expensive external C++ simulator; use small evaluation budgets when testing.
%
%   Example:
%
%       names = solar_select(struct('ptype', 'n', 'maxdim', 20));
%
%   See also SOLAR_LOAD, SOLAR_COLLECT_INFO.

    if nargin < 1
        problem_names = solar_matlab_select();
    else
        problem_names = solar_matlab_select(options);
    end
end
