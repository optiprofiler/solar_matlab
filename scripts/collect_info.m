repo_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(repo_dir);

problems = solar_metadata();
n_problems = numel(problems);
names = cell(n_problems, 1);
ptype = cell(n_problems, 1);
dim = zeros(n_problems, 1);
mb = zeros(n_problems, 1);
mlcon = zeros(n_problems, 1);
mnlcon = zeros(n_problems, 1);
mcon = zeros(n_problems, 1);

for i_problem = 1:n_problems
    problem = problems(i_problem);
    names{i_problem} = problem.name;
    dim(i_problem) = problem.n;
    mb(i_problem) = sum(isfinite(problem.xl)) + sum(isfinite(problem.xu));
    mlcon(i_problem) = 0;
    mnlcon(i_problem) = problem.m_constraints;
    mcon(i_problem) = problem.m_constraints;
    if problem.m_constraints > 0
        ptype{i_problem} = 'n';
    elseif mb(i_problem) > 0
        ptype{i_problem} = 'b';
    else
        ptype{i_problem} = 'u';
    end
end

rows = table(names, ptype, dim, mb, mlcon, mnlcon, mcon, ...
    'VariableNames', {'name', 'ptype', 'dim', 'mb', 'mlcon', 'mnlcon', 'mcon'});
writetable(rows, fullfile(repo_dir, 'probinfo_matlab.csv'));

fields = {'name', 'ptype', 'dim', 'mb', 'mlcon', 'mnlcon', 'mcon'};
probinfo = cell(height(rows) + 1, numel(fields));
probinfo(1, :) = fields;
for i = 1:height(rows)
    probinfo{i + 1, 1} = rows.name{i};
    probinfo{i + 1, 2} = rows.ptype{i};
    probinfo{i + 1, 3} = int2str(rows.dim(i));
    probinfo{i + 1, 4} = int2str(rows.mb(i));
    probinfo{i + 1, 5} = int2str(rows.mlcon(i));
    probinfo{i + 1, 6} = int2str(rows.mnlcon(i));
    probinfo{i + 1, 7} = int2str(rows.mcon(i));
end
probinfo = cell_to_padded_char_cube(probinfo);
mat_path = fullfile(repo_dir, 'probinfo_matlab.mat');
save(mat_path, 'probinfo', '-v6');
normalize_mat_file_header(mat_path);

fprintf('Wrote %s\n', fullfile(repo_dir, 'probinfo_matlab.csv'));
fprintf('Wrote %s\n', mat_path);

function cube = cell_to_padded_char_cube(values)
    max_len = 1;
    for i = 1:numel(values)
        max_len = max(max_len, length(values{i}));
    end

    cube = repmat(' ', size(values, 1), size(values, 2), max_len);
    for i = 1:size(values, 1)
        for j = 1:size(values, 2)
            value = values{i, j};
            cube(i, j, 1:length(value)) = value;
        end
    end
end

function normalize_mat_file_header(mat_path)
    fid = fopen(mat_path, 'r+');
    if fid < 0
        error('SOLAR:CollectInfo', 'Could not normalize MAT header: %s', mat_path);
    end
    cleanup = onCleanup(@() fclose(fid));

    header = 'MATLAB 5.0 MAT-file, Platform: OptiProfiler, Created by solar_matlab/scripts/collect_info.m';
    if length(header) > 116
        header = header(1:116);
    end
    header = [header repmat(' ', 1, 116 - length(header))];
    fwrite(fid, uint8(header), 'uint8');
end
