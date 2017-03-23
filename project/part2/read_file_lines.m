function [files] = read_file_lines(fpath, prefix, suffix)
    fid = fopen(fpath); % open file
    files= textscan(fid, '%s', 'delimiter', '\n'); % read each line
    fclose(fid);
     
    if nargin > 1 % if prefix is provided, append to each entry
       files = strcat(prefix, files{1}, suffix);
    end
end
