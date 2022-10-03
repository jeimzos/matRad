function qi = matRad_calcQualityIndicators_LETVH(cst,pln,letCube,refLET,refVol)
% matRad QI calculation
% 
% call
%   qi = matRad_calcQualityIndicators_LETVH(cst,pln,letCube)
%   qi = matRad_calcQualityIndicators_LETVH(cst,pln,letCube,refLET,refVol)
%
% input
%   cst:                matRad cst struct
%   pln:                matRad pln struct
%   letCube:            arbitrary letCube (LET)
%   refLET: (optional)   array of LET values used for V_XLET calculation
%                       default is [40 50 60]
%   refVol:(optional)   array of volumes (0-100) used for LET_X calculation
%                       default is [2 5 95 98]
%                       NOTE: Call either both or none!
%
% output
%   qi                  letvh indices   
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


matRad_cfg = MatRad_Config.instance();

if ~exist('refVol', 'var') || isempty(refVol)
    refVol = [2 5 50 95 98];
end

if ~exist('refLET', 'var') || isempty(refLET)
    refLET = floor(linspace(0,max(letCube(:)),6)*10)/10;
end

    
% calculate QIs per VOI
qi = struct;
for runVoi = 1:size(cst,1)
    
    indices     = cst{runVoi,4}{1};
    numOfVoxels = numel(indices); 
    voiPrint = sprintf('%3d %20s',cst{runVoi,1},cst{runVoi,2}); %String that will print quality indicators
    
    % get LET, LET is sorted to simplify calculations
    letInVoi    = sort(letCube(indices));
        
    if ~isempty(letInVoi)
        
        qi(runVoi).name = cst{runVoi,2};
        
        % easy stats
        qi(runVoi).mean = mean(letInVoi);
        qi(runVoi).std  = std(letInVoi);
        qi(runVoi).max  = letInVoi(end);
        qi(runVoi).min  = letInVoi(1);

        voiPrint = sprintf('%s - Mean LET = %5.2f keV/µm +/- %5.2f keV/µm (Max LET = %5.2f keV/µm, Min LET = %5.2f keV/µm)\n%27s', ...
                           voiPrint,qi(runVoi).mean,qi(runVoi).std,qi(runVoi).max,qi(runVoi).min,' ');

        LX = @(x) matRad_interp1(linspace(0,1,numOfVoxels),letInVoi,(100-x)*0.01);
        VX = @(x) numel(letInVoi(letInVoi >= x)) / numOfVoxels;

        % create VX and LX struct fieldnames at runtime and fill
        for runLX = 1:numel(refVol)
            qi(runVoi).(strcat('LE_',num2str(refVol(runLX)))) = LX(refVol(runLX));
            voiPrint = sprintf('%sLET%d%% = %7.3f keV/µm, ',voiPrint,refVol(runLX),LX(refVol(runLX)));
        end
        voiPrint = sprintf('%s\n%27s',voiPrint,' ');
        for runVX = 1:numel(refLET)
            sRefLET = num2str(refLET(runVX),3);
            qi(runVoi).(['V_' strrep(sRefLET,'.','_') 'keVum']) = VX(refLET(runVX));
            voiPrint = sprintf(['%sV' sRefLET 'keVum = %6.2f%%, '],voiPrint,VX(refLET(runVX))*100);
        end
        voiPrint = sprintf('%s\n%27s',voiPrint,' ');

        % if current voi is a target -> calculate homogeneity and conformity
        if strcmp(cst{runVoi,3},'TARGET') > 0      
            if referenceLET == inf 
                voiPrint = sprintf('%s%s',voiPrint,'Warning: target has no objective that penalizes underLET, ');
            else
 
                StringReferenceLET = regexprep(num2str(round(referenceLET*100)/100),'\D','_');
                % Conformity Index, fieldname contains reference LET
                VTarget95 = sum(letInVoi >= 0.95*referenceLET); % number of target voxels recieving LET >= 0.95 LPres
                VTreated95 = sum(letCube(:) >= 0.95*referenceLET);  %number of all voxels recieving LET >= 0.95 LPres ("treated volume")
                qi(runVoi).(['CI_' StringReferenceLET 'keVum']) = VTarget95^2/(numOfVoxels * VTreated95); 

                % Homogeneity Index (one out of many), fieldname contains reference LET        
                qi(runVoi).(['HI_' StringReferenceLET 'keVum']) = (LX(5) - LX(95))/referenceLET * 100;

                voiPrint = sprintf('%sCI = %6.4f, HI = %5.2f for reference LET of %3.1f keVum\n',voiPrint,...
                                   qi(runVoi).(['CI_' StringReferenceLET 'keVum']),qi(runVoi).(['HI_' StringReferenceLET 'LET']),referenceLET);
            end
        end
        %We do it this way so the percentages in the string are not interpreted as format specifiers
        matRad_cfg.dispInfo('%s\n',voiPrint);    
    else        
        matRad_cfg.dispInfo('%d %s - No LET information.',cst{runVoi,1},cst{runVoi,2});        
    end
end

% assign VOI names which could be corrupted due to empty structures
listOfFields = fieldnames(qi);
for i = 1:size(cst,1)
  indices     = cst{i,4}{1};
  letInVoi    = sort(letCube(indices));
  if isempty(letInVoi)
      for j = 1:numel(listOfFields)
          qi(i).(listOfFields{j}) = NaN;
      end
      qi(i).name = cst{i,2};
  end
end

end