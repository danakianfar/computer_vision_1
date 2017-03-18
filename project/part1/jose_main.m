clear, clc

MU1 = [2 2];
SIGMA1 = [2 0; 0 1];
MU2 = [-2 -1];
SIGMA2 = [1 0; 0 1];
rng(1); % For reproducibility
X1 = [mvnrnd(MU1,SIGMA1,1000);mvnrnd(MU2,SIGMA2,1000)];

clustering_res = execute_clustering(X1,'kmeans',2, true);

X2 = [mvnrnd(MU1,SIGMA1,100); mvnrnd(MU2,SIGMA2,100)];

idx = find_closest_visual_word(X2, clustering_res, true);