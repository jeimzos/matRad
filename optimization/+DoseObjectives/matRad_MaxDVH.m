classdef matRad_MaxDVH < DoseObjectives.matRad_DoseObjective
    %MATRAD_DOSEOBJECTIVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        name = 'Max DVH';
        parameterNames = {'d', 'V^{max}'};
        parameterTypes = {'dose','numeric'};
    end
    
    properties
        parameters = {30,95};
        penalty = 1;
    end
    
    methods 
        function obj = matRad_MaxDVH(penalty,dRef,vMaxPercent)
            if nargin >= 3 && isscalar(vMaxPercent)
                obj.parameters{2} = vMaxPercent;
            end
            
            if nargin >= 2 && isscalar(dRef)
                obj.parameters{1} = dRef;
            end
            
            if nargin >= 1 && isscalar(penalty)
                obj.penalty = penalty;
            end
        end        
        
        %% Calculates the Objective Function value
        function fDose = computeDoseObjectiveFunction(obj,dose)                       
            % get reference Volume
            refVol = obj.parameters{2}/100;
            
            % calc deviation
            deviation = dose - obj.parameters{1};

            % calc d_ref2: V(d_ref2) = refVol
            d_ref2 = matRad_calcInversDVH(refVol,dose);

            
            deviation(dose < obj.parameters{1} | dose > d_ref2) = 0;
   
            % claculate objective function
            fDose = (obj.penalty/numel(dose))*(deviation'*deviation);
        end
        
        %% Calculates the Objective Function gradient
        function fDoseGrad   = computeDoseObjectiveGradient(obj,dose)
            % get reference Volume
            refVol = obj.parameters{2}/100;
            
            % calc deviation
            deviation = dose - obj.parameters{1};
            
            % calc d_ref2: V(d_ref2) = refVol
            d_ref2 = matRad_calcInversDVH(refVol,dose);
            
            deviation(dose < obj.parameters{1} | dose > d_ref2) = 0;

            % calculate delta
            fDoseGrad = 2 * (obj.penalty/numel(dose))*deviation;
        end
    end
    
end
