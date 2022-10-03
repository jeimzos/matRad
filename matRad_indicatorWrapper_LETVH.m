function [letvh,qi] = matRad_indicatorWrapper_LETVH(cst,pln,resultGUI,refLET,refVol)
% matRad indictor wrapper
% 
% call
%   [letvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI)
%   [letvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI,refLET,refVol)
%
% input
%   cst:                  matRad cst struct
%   pln:                  matRad pln struct
%   resultGUI:            matRad resultGUI struct
%   refLET: (optional)     array of LET values used for V_XLET calculation
%                         default is [40 50 60]
%   refVol:(optional)     array of volumes (0-100) used for D_LET calculation
%                         default is [2 5 95 98]
%                         NOTE: Call either both or none!
%
% output
%   letvh: matRad letvh result struct
%   qi:  matRad letvh indices struct
%   graphical display of all results
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

letCube = resultGUI.LET; %

if ~exist('refVol', 'var') 
    refVol = [];
end

if ~exist('refLET', 'var')
    refLET = [];
end

letvh = matRad_calcLETVH(cst,letCube,'cum');
qi  = matRad_calcQualityIndicators_LETVH(cst,pln,letCube,refLET,refVol);

figure,set(gcf,'Color',[1 1 1]);
subplot(2,1,1)
matRad_showLETVH(letvh,cst,pln);
subplot(2,1,2)
ixVoi = cellfun(@(c) c.Visible == 1,cst(:,5));
qi = qi(ixVoi);
matRad_showQualityIndicators_LETVH(qi);