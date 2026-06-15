function problem = solar_load(problem_name)
%SOLAR_LOAD converts a SOLAR problem name to a Problem class instance.
%
%   PROBLEM = SOLAR_LOAD(PROBLEM_NAME) returns a Problem class instance
%   PROBLEM that corresponds to the enabled scalar SOLAR problem named
%   PROBLEM_NAME. SOLAR is a black-box solar-plant simulation benchmark; more
%   details about the upstream benchmark can be found at
%   <https://github.com/bbopt/solar>.
%
%   You may use the function `solar_select` to get problem names satisfying
%   dimension and constraint criteria.
%
%   The returned Problem contains the objective function and, when present,
%   nonlinear inequality constraints. SOLAR does not provide derivatives in this
%   wrapper.
%
%   The SOLAR C++ executable is built on first use if it is missing. This first
%   build can take noticeably longer than an ordinary load call.
%
%   Several scalar SOLAR instances include integer or categorical variables.
%   Before calling the SOLAR executable, this wrapper rounds every `I`
%   coordinate to the nearest integer and clips it to the integer bounds
%   recorded in the metadata.
%
%   SOLAR returns objective and constraint values from one executable call. This
%   wrapper may cache that raw executable result internally, but it does not call
%   OptiProfiler-visible `cub` from `fun`, or `fun` from `cub`. This preserves
%   OptiProfiler's separate objective and constraint evaluation histories.

    problem = solar_matlab_load(problem_name);
end
