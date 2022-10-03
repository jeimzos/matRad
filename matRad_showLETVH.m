function matRad_showLETVH(letvh,cst,pln,lineStyleIndicator)
% matRad letvh visualizaion
% 
% call
%   matRad_showLETVH(letvh,cst)
%   matRad_showLETVH(letvh,cst,pln)
%   matRad_showLETVH(letvh,cst,lineStyleIndicator)
%   matRad_showLETVH(letvh,cst,pln,lineStyleIndicator)
%
% input
%   letvh:              result struct from fluence optimization/sequencing
%   cst:                matRad cst struct
%   pln:                (now optional) matRad pln struct,
%                       standard uses LET [keV/µm]
%   lineStyleIndicator: (optional) integer (1,2,3,4) to indicate the current linestyle
%                       (hint: use different lineStyles to overlay
%                       different letvhs)
%
% output
%   graphical display of LETVH   
%
% References
%   -
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('lineStyleIndicator','var') || isempty(lineStyleIndicator)
    lineStyleIndicator = 1;
end

% create new figure and set default line style indicator if not explictly
% specified
hold on;

%reduce cst
visibleIx = cellfun(@(c) c.Visible == 1,cst(:,5));
cstNames = cst(visibleIx,2);
cstInfo = cst(visibleIx,5);
letvh = letvh(visibleIx);

numOfVois = numel(cstNames);
        
%% print the letvh

%try to get colors from cst
try
    colorMx = cellfun(@(c) c.visibleColor,cstInfo,'UniformOutput',false);
    colorMx = cell2mat(colorMx);
catch
    colorMx    = colorcube;
    colorMx    = colorMx(1:floor(64/numOfVois):64,:);
end

lineStyles = {'-',':','--','-.'};

maxLETVHvol  = 0;
maxLETVHlet = 0;

for i = 1:numOfVois
    % cut off at the first zero value where there is no more signal
    % behind
    ix      = max([1 find(letvh(i).volumePoints>0,1,'last')]);
    currLETvh = [letvh(i).letGrid(1:ix);letvh(i).volumePoints(1:ix)];
    
    plot(currLETvh(1,:),currLETvh(2,:),'LineWidth',4,'Color',colorMx(i,:), ...
        'LineStyle',lineStyles{lineStyleIndicator},'DisplayName',cstNames{i})
    
    maxLETVHvol  = max(maxLETVHvol,max(currLETvh(2,:)));
    maxLETVHlet  = max(maxLETVHlet,max(currLETvh(1,:)));
end

fontSizeValue = 14;
myLegend = legend('show','location','NorthEast');
set(myLegend,'FontSize',10,'Interpreter','none');
legend boxoff %

ylim([0 1.1*maxLETVHvol]);
xlim([0 1.2*maxLETVHlet]);

grid on,grid minor
box(gca,'on');
set(gca,'LineWidth',1.5,'FontSize',fontSizeValue);
ylabel('Volume [%]','FontSize',fontSizeValue)
xlabel('LET [keV/µm]','FontSize',fontSizeValue);
end