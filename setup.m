function setup(volatile)
% Description:
% This function sets up the necessary paths for the execution of the stock 
% market prediction project. It adds specific directories to the MATLAB 
% path, enabling access to relevant datasets, libraries, and utilities
% required for the project.
% 
% Usage:
% - setup() initializes the required paths.
%   - If no argument is provided, the paths are saved for future sessions.
%   - If the argument is set to 1, the paths are modified only for the 
%       current session.
%
if ispc
    addpath("datasets\mat\")
    addpath("libs")             
    addpath("libs\map")
else
    addpath("datasets/mat/")
    addpath("libs")             
    addpath("libs/map")
end
    if (nargin > 0 && volatile==1)
        disp("Path will be modified only for current session.");
    else
        savepath
        disp("Path will be saved across different sessions.")
    end