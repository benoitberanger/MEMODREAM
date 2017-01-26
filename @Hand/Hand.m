classdef Hand < handle
    %HAND Load a .png transparent file and get it ready for disply via PTB
    
    %% Properties
    
    properties
        
        path       = char         % full path of the .png file
        flipedLR   = false(0)     % has been flipped ?
        
        wPx        = zeros(0)     % width  in Pixels
        hPx        = zeros(0)     % height in Pixels
        
        imgRaw     = zeros(0,0)   % .png
        imgMiddle  = zeros(0,0)   % transformed .png
        imgFinal   = zeros(0,0,4) % ready for PTB MakeTexture : NxM matrix of [R G B a]
        texture    = zeros(0)     % PTB texture pointer
        scale      = zeros(0)     % from 0 to +Inf
        baseRect   = zeros(0,4)   % [ x y w h ] from 0 to +Inf, no scale applied
        baseCenter = zeros(0,2)   % [ x y ] from 0 to +Inf, no scale applied
        
        rect       = zeros(0,4)   % [ x y w h ] from 0 to +Inf, scale applied, centered
        center     = zeros(0,2)   % [ x y ] from 0 to +Inf, scale applied
        
        color      = zeros(0,4)   % [R G B a] from 0 to 255
        wPtr       = zeros(0)     % PTB window pointer
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Hand( imgpath , color ,  needtoflip )
            % obj = EventRecorder( imgpath = 'path/to/myImg.png' , color = [R G B a] from 0 to 255 , needtoflip = false/true ).
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- imgpath ----
                assert( ischar(imgpath) , 'imgpath must be char 1xn' )
                
                % --- color ----
                assert( isvector(color) && isnumeric(color) && all( uint8(color)==color ) , 'color = [R G B a] from 0 to 255' )
                
                % --- needtoflip ----
                if nargin < 3
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
                obj.color        = color; % [R G B a] from 0 to 255
                obj.imgMiddle    = obj.imgRaw;
                obj.imgFinal     = uint8( cat( 3, obj.imgMiddle*obj.color(1) , obj.imgMiddle*obj.color(2) , obj.imgMiddle*obj.color(3) , obj.imgMiddle*(obj.color(4)/255) ) );
                
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
