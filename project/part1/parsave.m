% https://nl.mathworks.com/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox
function parsave(fpath, varname)
    save(fpath, varname, '-v6')
end
