function MakeTexture( obj , wPtr )


%% Texture parameters

% MakeTexture_specialFlags = bin2dec('0 0 0 1 1 1'); % See Screen('MakeTexture?')
MakeTexture_specialFlags = []; % See Screen('MakeTexture?')

% glsl = MakeTextureDrawShader( wPtr , 'SeparateAlphaChannel' );
glsl = [];


%% Make PTB texture

obj.texture = Screen( 'MakeTexture' , wPtr , obj.imgFinal ,[] , MakeTexture_specialFlags , [] , [] , glsl );
obj.wPtr = wPtr;


end

