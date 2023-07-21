disp("Init")

stock_name = "datasets/mat/AAPL.mat";
load(stock_name);       % Date Open Close High Low

% see train section: if 0 a specified .mat file is loaded
%                    if 1 a new training is done
TRAIN = 0;

if (~TRAIN)
    filename = ("train/hmmtrain-2023-07-14-00-34-47.mat");
    load(filename);
end

% see sequences train section: if 0 a new sequence is grouped every #days = latency
%                              if 1 a new sequence is grouped every day
shiftWindowByOne = 0;

% select training period, date format YYYY-MM-DD
startTrainDate = '2019-01-03';
endTrainDate   = '2022-01-03';
startTrainDateIdx = indexOfDate(Date, startTrainDate);
endTrainDateIdx   = indexOfDate(Date, endTrainDate);
trainIndexes = startTrainDateIdx:endTrainDateIdx;

% select prediction period, date format YYYY-MM-DD 
startPredictionDate = '2023-01-03';
endPredictionDate   = Date(end);       
startPredictionDateIdx = indexOfDate(Date, startPredictionDate);
endPredictionDateIdx   = indexOfDate(Date, endPredictionDate);    
predictionLength = endPredictionDateIdx - startPredictionDateIdx + 1;
predictionIndexes = startPredictionDateIdx:endPredictionDateIdx;

% dynamic edges for discretization: -   if 1, edges are changed accordingly to
%                                       training set
%                                   -   if 0, default values for edges are
%                                       used
useDynamicEdges = 0;

discretizationPoints = [50 10 10];    % uniform intervals to discretize observed parameters
totalDiscretizationPoints = discretizationPoints(1)*discretizationPoints(2)*discretizationPoints(3);

underlyingStates = 4; % number of hidden states
mixturesNumber = 4;   % number of mixture components for each state
latency = 10;         % days aka vectors in sequence
