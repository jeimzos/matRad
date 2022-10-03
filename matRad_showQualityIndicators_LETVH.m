function matRad_showQualityIndicators_LETVH(qi)
% matRad display of quality indicators as table
% 
% call
%   matRad_showQualityIndicators_LETVH(qi)
%
% input
%   qi: result struct from matRad_calcQualityIndicators_LETVH
%
% output
%   graphical display of letvh indices in table form   
%
% References
%   -
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matRad_cfg = MatRad_Config.instance();

[env, vStr] = matRad_getEnvironment();
    
% Create the column and row names in cell arrays 
rnames = {qi.name};
qi = rmfield(qi,'name');
cnames = fieldnames(qi);
for i = 1:numel(cnames)
    ix = find(cnames{i}(4:end) == '_');
    if ~isempty(ix)
        cnames{i}(ix+3) = '.';
    end
end

%To avoid parse error in octave, replace empty qi values with '-'
qi = (squeeze(struct2cell(qi)))';
qiEmpty = cellfun(@isempty,qi);
qi(qiEmpty) = {'-'};

%since uitable is only available in newer octave versions, we try and catch
try
    % Create the uitable
    table = uitable(gcf,'Data',qi,...
        'ColumnName',cnames,...
        'RowName',rnames,'ColumnWidth',{70});
    
    % Layout
    pos = get(gca,'position');
    set(table,'units','normalized','position',pos)
    axis off
catch ME
    matRad_cfg.dispWarning('The uitable function is not implemented in %s v%s.',env,vStr);
end