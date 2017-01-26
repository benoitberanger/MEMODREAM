classdef Fingers < handle
    %HAND Load a .png transparent file and get it ready for disply via PTB
    
    %% Properties
    
    properties
        
        basePos   = zeros(5,2) % [ x1 y1 ; x2 y2 ; ... ] in Pixels
        baseRects = zeros(4,5) % rows are PTB rectangles, in Pixels
        flipedLR  = false(0)            % has been flipped ?
        
        scale      = zeros(0)  % from 0 to +Inf
        
        pos       = zeros(5,2) % [ x1 y1 ; x2 y2 ; ... ] in Pixels
        rects     = zeros(4,5) % rows are PTB rectangles, in Pixels
        
        color     = zeros(0,4) % [R G B a] from 0 to 255
        handPtr   = zeros(0)   % PTB window pointer
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Fingers( pos )
            % obj = EventRecorder( imgpath = 'path/to/myImg.png' ).
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- pos ----
                assert( size(pos,1)==5 && size(pos,2)==2 , 'pos must be 5x2 matrix' )
                assert( all( round(pos(:)) == pos(:) ) && all( pos(:)>0 ) , 'all elements in pos must be positive integers' )
                
                
                % ================== Callback =============================
                
                obj.color     = repmat([255 0 0 180], [5 1] )'; % [R G B a] from 0 to 255
                
                obj.scale     = 1;
                
                obj.basePos   = pos;
                obj.baseRects = obj.MakeRects('basePos');
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
