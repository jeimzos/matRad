function letvh = matRad_calcLETVH(cst,letCube,letvhType,letGrid)
% matRad letvh calculation
% 
% call
%   letvh = matRad_calcLETVH(cst,letCube)
%   letvh = matRad_calcLETVH(cst,letCube,letvhType)
%   letvh = matRad_calcLETVH(cst,letCube,LETGrid)
%   letvh = matRad_calcLETVH(cst,letCube,letvhType,letGrid)
%
% input
%   cst:        matRad cst struct
%   letCube:   arbitrary letCube (LET equivalent of 'doseCube')
%   letvhType:  (optional) string, 'cum' for cumulative, 'diff' for differential
%               letvh
%   letGrid:    (optional) use predefined evaluation points. Useful when
%               comparing multiple realizations
%
% output
%   linear energy transfer volume histogram
%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('letvhType','var') || isempty(letvhType)
    letvhType = 'cum';
end

if ~exist('letGrid', 'var') || isempty(letGrid)
    maxLET = max(letCube(:));
    minLET = min(letCube(:));

    % get letPoints for every structure and every scenario the same
    n = 1000;
    if strcmp(letvhType, 'cum')
        letGrid = linspace(0,maxLET*1.05,n);
    elseif strcmp(letvhType, 'diff')
        letGrid = linspace(0.95*minLET,maxLET*1.05,n);
    end
end

numOfVois = size(cst,1);
letvh = struct;
for i = 1:numOfVois
    letvh(i).letGrid     = letGrid;
    letvh(i).volumePoints = getLETVHPoints(cst, i, letCube, letGrid, letvhType);
    letvh(i).name         = cst{i,2};
end

end %eof 

function letvh = getLETVHPoints(cst, sIx, letCube, letvhPoints, letvhType)
n = numel(letvhPoints);
letvh       = NaN * ones(1,n);
indices     = cst{sIx,4}{1};
numOfVoxels = numel(indices);

letInVoi   = letCube(indices);

switch letvhType
    case 'cum' % cummulative LETVH
        for j = 1:n
            letvh(j) = sum(letInVoi >= letvhPoints(j));
        end

    case 'diff' % differential LETVH
        binning = (letvhPoints(2) - letvhPoints(1))/2;
        for j = 1:n % differential LETVH        
            letvh(j) = sum(letvhPoints(j) + binning > letInVoi & letInVoi > letvhPoints(j) - binning);
        end

end
letvh = letvh ./ numOfVoxels * 100;
end %eof getLETVHPoints