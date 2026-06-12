function probinfo = solar_matlab_collect_info()
%SOLAR_MATLAB_COLLECT_INFO returns SOLAR metadata rows used by solar_matlab_select.

    load(fullfile(fileparts(mfilename('fullpath')), 'probinfo_matlab.mat'), 'probinfo');
end
