function [ map ] = mean_avg_precision(ranking)
%MEAN_AVG_PRECISION Calculates the mean average precision MAP of the
%provided ranking
%
% Inputs:
%   RANKING: N dimensional binary vector: 1 means relevant
%
% Outputs:
%   MAP: Mean average precision of the provided ranking
%
    N = length(ranking);
    M = sum(ranking);
    map = sum( ranking .* cumsum(ranking) ./ [1:N]' ) / M;

end