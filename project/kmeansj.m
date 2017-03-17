%KMEANS k-means clustering
%
%   [LABELS,A, CLUST] = KMEANSJ(A,K,MAXIT,INIT,FID, DOPLOT)
%
%   Jasper: Slightly modified version of k-means: now also output
%   the cluster centers CLUST itself
%   Can also use a more intelligent initialization based on Arhur and
%   Vassilvitskii
%   Furthermore it is made more memory efficient by getting rid of the
%   nmc classifier and instead use a direct assignment created in the
%   functions nnassign and clusterCenters at the bottom of this file
%
% INPUT
%  A       Matrix or dataset
%  K       Number of clusters to find (optional; default: 2)
%  MAXIT   maximum number of iterations (optional; default: 50)
%  INIT    Labels for initialisation, or
%          'rand'     : take at random K objects as initial means, or
%          'kcentres' : use KCENTRES for initialisation (default)
%  FID     File ID to write progress to (default [], see PRPROGRESS)
%  DOPLOT  If PLOT == 1 then plot the kmeans analysis.
%
% OUTPUT
%  LABELS  Cluster assignments, 1..K
%  A       Dataset with original data and labels LABELS
%  CLUST   Cluster centres
% 
% DESCRIPTION
% K-means clustering of data vectors in A. 
%
% SEE ALSO
% DATASETS, HCLUST, KCENTRES, MODESEEK, EMCLUST, PRPROGRESS
%
% REFERENCES
% 1. D. Arthur and Sergei Vassilvitskii, k-means++: The advantages of
% Careful Seeding, Proceedings of the eighteenth annual ACM-SIAM symposium
% on Discrete algorithms, pag 1027-1035

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: kmeans.m,v 1.14 2005/10/05 09:30:45 duin Exp $

function [assign,a, clusters] = kmeansj(a,kmax,maxit,init,fid, doplot)

	prtrace(mfilename);

	n_ini = 100;				% Maximum size of subset to use for initialisation.

	if (nargin < 2) | isempty(kmax)
		kmax = 2; 
		%prwarning(3,'No K supplied, assuming K = 2.');
	end
	if nargin < 3 | isempty(maxit)
		maxit = 50;
	end
	if nargin < 4 | isempty(init)
		init = 'rand';
	end
	if nargin < 5
		fid = [];
    end
    
    if nargin < 6
        doplot = 0;
    end
    
    if doplot
        plotMap = FastPCA(a, 2);
        plotData = a * plotMap;
    end

	% Create dataset with all equal labels and no priors.
	a = dataset(a);
	islabtype(a,'crisp');
	m = size(a,1); 
    a=set(a,'labels',ones(m,1),'lablist',[1:kmax]','prior',[]); % for speed
	
	n_ini = max(n_ini,kmax*5);  % initialisation needs sufficient samples 
	
	% prprogress(fid,'\nkmeans clustering procedure\n')
	% Initialise by performing KCENTRES on...
	if (size(init,1) == 1) && strcmp(init,'kcentres') && (m > n_ini) 
		%prwarning(2,'Initializing by performing KCENTRES on subset of %d samples.', n_ini);
		b = +gendat(a,n_ini); % ... a random subset of A.
		d = +distm(b);
		assign = kcentres(d,kmax,[],fid);
        clusters = clusterCenters(+b, assign);
        assign = nnassign(+a, clusters);
	elseif (size(init,1) == 1) && strcmp(init,'kcentres')
		%prwarning(2,'Initializing by performing KCENTRES on training set.');
		d = +distm(a);    % ... the entire set A.
		assign = kcentres(d,kmax,[],fid);
        clusters = clusterCenters(+a, assign);
	elseif (size(init,1) == 1) && strcmp(init,'rand')
        % Get random cluster centers
   		R = randperm(m);
        clusters = +a(R(1:kmax),:);
        
    	assign = nnassign(+a, clusters);
        
%         % In the case of one cluster: return
%         if size(clusters,1) == 1
%             assign = ones(size(a,1),1);
%             return
%         end
       
    elseif (size(init,1) == 1) & strcmp(init,'careful')
        [idxSeed clusters] = KmeansGetCarefulSeed(a, kmax);
        assign = nnassign(+a, clusters);
	elseif (size(init,1) == m)
		assign = renumlab(init);
		% prwarning(2,'Initializing by given labels, k = %i',kmax);
        clusters = clusterCenters(+a, assign);
	else
		error('Wrong initialisation supplied')
    end

    % Main loop, while assignments change
	it=1; % number of iterations
	ndif = 1;

	while (it<maxit) & (ndif > 0)
		tmp_assign = assign;     % Remember previous assignments.
        clusters = clusterCenters(+a, assign);
        assign = nnassign(+a, clusters);
		it = it+1; % increase the iteration counter
		ndif = sum(tmp_assign ~= assign);
		% prprogress(fid,'  iter: %i changes: %i\n',it,ndif); 
        if doplot
            plotCentres = clusters * plotMap;
            plot(+plotData(:,1), +plotData(:,2), 'g.', +plotCentres(:,1), +plotCentres(:,2), 'k+');
            drawnow;
        end
	end
	
	if it>=maxit
		%prwarning(1,['No convergence reached before the maximum number of %d iterations passed. ' ...
			%'The last result was returned.'], maxit);
        % Final assignment of clusters
        clusters = clusterCenters(+a, assign);
    end
    
	% prprogress(fid,'kmeans finished\n')

return;

% Do a nearest neighbour assignment using the clusters.
function assignment = nnassign(data, clusters)

% Do in blocks because of memory
[num n] = prmem(size(data,1), size(clusters,1));

ranges = 1:n:size(data,1);

if(ranges(end) ~= size(data,1))
    ranges = [ranges size(data,1)];
end

assignment = zeros(size(data,1),1);

for i=1:(size(ranges,2)-1)
    iB = ranges(i);
    iE = ranges(i+1);
    
    % Actual assignment
    [minimum assignment(iB:iE)] = min(distmj(data(iB:iE,:), clusters), [], 2);
end

% Calculate cluster centres from the data and it's assignment
function clusters = clusterCenters(data, assign)

labelSet = unique(assign);
clusters = zeros(length(labelSet), size(data,2));
for i=1:length(labelSet)
    clusters(i,:) = mean(data(assign == labelSet(i),:),1);
end


