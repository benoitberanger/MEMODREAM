classdef Hand < handle
    %HAND Load a .png transparent file and get it ready for disply via PTB
    
    %% Properties
    
    properties
        
        path       = char                  % full path of the .png file
        flipedLR   = false(0)              % has been flipped ?
        
        wPx        = zeros(0,'uint16')     % width  in Pixels
        hPx        = zeros(0,'uint16')     % height in Pixels
        
        imgRaw     = zeros(0,0,'uint16')   % .png
        imgMiddle  = zeros(0,0,'uint16')   % transformed .png
        imgFinal   = zeros(0,0,4,'uint16') % ready for PTB MakeTexture : NxM matrix of [R G B a]
        texture    = zeros(0,'uint16')     % PTB texture pointer
        scale      = zeros(0,'double')     % from 0 to +Inf
        baseRect   = zeros(0,4,'uint16')   % [ x y w h ] from 0 to +Inf, no scale applied
        baseCenter = zeros(0,2,'uint16')   % [ x y ] from 0 to +Inf, no scale applied
        
        rect       = zeros(0,4,'uint16')   % [ x y w h ] from 0 to +Inf, scale applied, centered
        center     = zeros(0,2,'uint16')   % [ x y ] from 0 to +Inf, scale applied
        
        color      = zeros(0,4,'uint8')    % [R G B] from 0 to 255
        wPtr       = zeros(0,'uint8')      % PTB window pointer
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Hand( imgpath , needtoflip )
            % obj = EventRecorder( imgpath = 'path/to/myImg.png' ).
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- imgpath ----
                assert( ischar(imgpath) , 'imgpath must be char 1xn' )
                
                % --- needtoflip ----
                if nargin < 2
                    needtoflip = false;
                else
                    assert( isscalar(needtoflip) && islogical(needtoflip) , 'needtoflip must be logical 1x1' )
                end
                
                
                % ================== Callback =============================
                
                obj.path         = imgpath;
                obj.flipedLR     = needtoflip;
                [~,~,obj.imgRaw] = imread( imgpath );
                obj.wPx          = size(obj.imgRaw,1);
                obj.hPx          = size(obj.imgRaw,2);
                if needtoflip
                    obj.imgRaw   = fliplr(obj.imgRaw);
                end
                obj.color        = [0 0 255];
                obj.imgMiddle    = obj.imgRaw > 10;
                obj.imgFinal     = uint8( cat( 3, obj.imgMiddle*obj.color(1) , obj.imgMiddle*obj.color(2) , obj.imgMiddle*obj.color(3) , obj.imgMiddle*255 ) );
                
                obj.baseRect     = [0 0 obj.wPx obj.hPx];
                obj.baseCenter   = [obj.wPx/2 obj.hPx/2];
                
                obj.scale        = 1;
                obj.ReScale(obj.scale); % to generate center and rect for the first time
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
