function problem_names = solar_select(options)
%SOLAR_SELECT compatibility alias for solar_matlab_select.

    if nargin < 1
        problem_names = solar_matlab_select();
    else
        problem_names = solar_matlab_select(options);
    end
end
