function [clusterMeans, clusterVariances] = kmeansMeanVariance(points, k)
    % Perform k-means clustering
    [idx, ~] = kmeans(points, k);
    
    % Initialize variables
    clusterMeans = zeros(k, size(points, 2));
    clusterVariances = zeros(k, size(points, 2));
    
    % Calculate mean and variance for each cluster
    for i = 1:k
        clusterPoints = points(idx == i, :);
        clusterMeans(i, :) = mean(clusterPoints);
        clusterVariances(i, :) = var(clusterPoints);
    end
end
