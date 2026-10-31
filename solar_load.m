function problem = solar_load(problem_name)
%SOLAR_LOAD converts a SOLAR problem name to a Problem class instance.
%
%   PROBLEM = SOLAR_LOAD(PROBLEM_NAME) returns a Problem class instance
%   PROBLEM that corresponds to the enabled scalar SOLAR problem named
%   PROBLEM_NAME. More details about the upstream SOLAR benchmark can be found
%   at <https://github.com/bbopt/solar>.
%
%   The SOLAR MATLAB adapter vendors a slim SOLAR runtime. Its C++ sources declare
%   LGPL-3.0-or-later, and the upstream makefile and README follow the LGPL-2.1
%   license file of the upstream repository. See THIRD_PARTY_NOTICES.md for the
%   complete inventory. The runtime keeps its upstream license, README, and
%   manifest under `runtime/solar/`. Some SOLAR problems call a comparatively
%   expensive external C++ simulator; use small evaluation budgets when testing.
%
%   You may use the function `solar_select` to get the problem names you want.
%
%   The returned Problem contains the objective function and, when present, the
%   nonlinear inequality constraint function. SOLAR does not provide derivative
%   functions in this wrapper.
%
%   Note that the SOLAR C++ executable is built on first use if it is missing.
%   This first build can take noticeably longer than an ordinary load call.
%
%   Several scalar SOLAR instances include integer or categorical variables. The
%   wrapper rounds every `I` coordinate to the nearest integer and clips it to
%   the integer bounds recorded in the metadata before calling SOLAR. This is a
%   wrapper-level mixed-integer handling rule, not a claim that these instances
%   are native continuous problems.
%
%   SOLAR returns objective and constraint values from one executable call. This
%   wrapper may cache that raw executable result internally, but it does not call
%   OptiProfiler-visible `cub` from `fun`, or `fun` from `cub`. This preserves
%   OptiProfiler's separate objective and constraint evaluation histories.
%
%   See also SOLAR_SELECT, SOLAR_COLLECT_INFO.

    problem = solar_matlab_load(problem_name);
end
