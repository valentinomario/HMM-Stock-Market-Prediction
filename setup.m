function setup(volatile)
    addpath("datasets\mat\")
    addpath("libs")             
    addpath("libs\map")
    if (nargin>0 && volatile~=1)
        savepath
    else
        disp("Path will be modified only for current session");
    end