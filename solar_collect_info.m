function probinfo = solar_collect_info()
%SOLAR_COLLECT_INFO returns SOLAR metadata rows used by solar_select.

    load(fullfile(fileparts(mfilename('fullpath')), 'probinfo_matlab.mat'), 'probinfo');
end
