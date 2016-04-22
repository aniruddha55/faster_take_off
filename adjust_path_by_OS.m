function fixed_path = adjust_path_by_OS(path)
fixed_path = path;
if ispc
    fixed_path = strrep(path, '/','\');
end