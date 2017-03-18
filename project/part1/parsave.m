% https://nl.mathworks.com/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox
function parsave(fpath, model)
    save(fpath, 'model', '-v6')
end
