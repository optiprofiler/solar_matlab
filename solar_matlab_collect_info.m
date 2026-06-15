function probinfo = solar_matlab_collect_info()
%SOLAR_MATLAB_COLLECT_INFO returns the SOLAR problem information table.
%
%   PROBINFO = SOLAR_MATLAB_COLLECT_INFO() is the MATLAB-specific
%   implementation used by the public entry point `solar_collect_info`. Users
%   should normally call `solar_collect_info`, whose name matches the
%   OptiProfiler problem library name `solar`.
%
%   The returned table is loaded from `probinfo_matlab.mat`, which is generated
%   by `scripts/collect_info.m` from the actual SOLAR_LOAD wrapper output.
%
%   See also SOLAR_COLLECT_INFO, SOLAR_SELECT, SOLAR_LOAD.

    load(fullfile(fileparts(mfilename('fullpath')), 'probinfo_matlab.mat'), 'probinfo');
end
