classdef GaussianBlur
   properties
      p {mustBeNumeric}
      kernelRange
      sigma
      isCustom
   end
   
   methods
       function obj = GaussianBlur(varargin)
           % Default vals.
           obj.p            = 0.5;
           obj.kernelRange  = [3 7];
           obj.sigma = 0;
           obj.isCustom = false;
           
           if nargin > 0
               obj.p = varargin{1};
           end
           if nargin > 1
               obj.kernelRange = varargin{2};
           end
           if nargin > 2
               obj.sigma = varargin{3};
               obj.isCustom = true;
           end
       end
       
       function [imgAugmented, varargout] = apply(obj, img, isConsistent, varargin)
           % Initialise output variables.
           varargout{1} = {};  % Params
           varargout{2} = {};  % Modified pose
           
           if isConsistent
               % Apply consistently with same parameters.
               [isApply,params] = fPrepConsistent(obj, varargin); 	% Input check
               
               if isApply
                   [imgAugmented, params] = gaussianBlur(obj,img,params);
                   [outIsRecord,outIsApply,outParams] = fPostApplyYes(params);
               else
                   imgAugmented = img;
                   [outIsRecord,outIsApply,outParams] = fPostApplyNo(varargin);
               end
               
               varargout{1} = {outIsRecord, outIsApply, outParams};
               
               % Otherwise, apply randomly generated parameters.
           else
               if rand > (1 - obj.p)
                   imgAugmented = gaussianBlur(obj,img);
               else
                   imgAugmented = img;
               end
           end
       end
      
       function [imgAugmented, varargout] = gaussianBlur(obj,img,varargin)
            % Input parsing
            nStaticArgs = 2;
            [isRandom,isRecord,params] = fFunPrep(nStaticArgs,varargin,nargin);
           
           imgAugmented = im2double(img);
           nChannels = size(img,3);
           
           if isRandom
               kernelHyp = obj.kernelRange(1):2:obj.kernelRange(2);
               kernelHyp = kernelHyp(randperm(length(kernelHyp)));
               kernelVal = kernelHyp(1);
               
               if isRecord
                   params = kernelVal;
               end
           else
               kernelVal = params;
           end
           
           if ~obj.isCustom
               sigma = 0.3*((kernelVal-1)*0.5 - 1) + 0.8; %#ok<*PROPLC>
           else
               sigma = obj.sigma;
           end
           
           for i = 1:nChannels
               imgAugmented(:,:,i) = imgaussfilt(imgAugmented(:,:,i), sigma, 'FilterSize', kernelVal);
           end
           
           imgAugmented = im2uint8(imgAugmented);
           
           % Post processing.
           outParams = fFunPost(isRecord,params);
           
           varargout{1} = outParams;
       end
       
   end
end