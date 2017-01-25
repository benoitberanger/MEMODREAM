function MakeTexture( obj , wPtr )

% MakeTexture_specialFlags = bin2dec('0 0 0 1 1 1'); % See Screen('MakeTexture?')
MakeTexture_specialFlags = []; % See Screen('MakeTexture?')

% glsl = MakeTextureDrawShader(DataStruct.PTB.Window, 'SeparateAlphaChannel' );
glsl = [];

obj.texture = Screen( 'MakeTexture' , wPtr , obj.imgFinal ,[] , MakeTexture_specialFlags , [] , [] , glsl );

obj.wPtr = wPtr;

end

