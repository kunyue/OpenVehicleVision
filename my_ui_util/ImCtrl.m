classdef ImCtrl<handle
    
    properties (GetAccess = public, SetAccess = private)
        func,argName,argValue
        h_uictrls,h_axes
        args_imshow
    end
    
    methods (Static)
    end
    
    methods (Access = public)
        function obj = ImCtrl(func, varargin)
            nargfixed = nargin - numel(varargin);
            obj.func = func;
            obj.argName = cell(1,numel(varargin));
            for n = 1:numel(varargin)
                obj.argName{n} = inputname(n+nargfixed);
            end
            obj.argValue = varargin;
        end
        
        function imshow(obj,varargin) % handle
            obj.h_uictrls = cell(1,numel(obj.argValue));
            obj.args_imshow = varargin;
            idx = 0;
            for n = 1:numel(obj.argValue)
                arg = obj.argValue{n};
                if isobject(arg) %&& superclass(arg)
                    idx = idx + 1;
                    
                    %TODO: if Position is not set
                    %TODO: panel or child figure
                    %NOTE: Axes cannot be a parent.
                    f = gcf;
					a = gca;
                    
                    % put uicontrol on the downside of axes
                    height = 20;
                    width = 180;
                    pos = a.Position .* [f.Position(3:4) 0 0] + [-100 50 0 0];
                    arg.Position = pos + [120 -height*n width height];
                    arg.Callback = @(h,ev)obj.callback_func();
                    
                    % plot
                    eval(sprintf('%s=arg;',obj.argName{n}));
                    eval(sprintf('obj.h_uictrls{n} = %s.plot();',obj.argName{n}));
                end
            end%for
            
            obj.h_axes = gca;
            obj.callback_func(); % call once
        end
        
        function callback_func(obj)
            % arg/args: read the uicontrol values
            args = obj.argValue; % do not change argValue
            
            % load args value
            fprintf(char(obj.func));
            for n = 1:numel(args)
                arg = args{n};
                
                % get value of uicontrols
                if isobject(arg) %&& superclass(arg)
                    args{n} = arg.val(obj.h_uictrls{n});
                end
                
                if n == 1
                    fprintf('(');
                else
                    fprintf(',');
                end
                
                str = tostring(args{n});
                if isempty(str)
                    fprintf('%s',obj.argName{n});
                else
                    fprintf(str);
                end
            end%for
            
            %if gca ~= h, axes(h);end
            %hold on; % keep the title
            fprintf(');\n');
            imshow(obj.func(args{:}),'Parent',obj.h_axes, obj.args_imshow{:});
        end
    end% methods
end% classdef