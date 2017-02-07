%% Load and prepare sprites for the hands

img_path = 'img';
img_file = [ img_path filesep 'left_hand.png' ];

hand_color = [0 128 255 255]; % [R G B a] from 0 to 255

LeftHand  = Hand(img_file, hand_color, false);
LeftHand. MakeTexture(wPtr);

RightHand = Hand(img_file, hand_color, true );
RightHand.MakeTexture(wPtr);


%% Scale and shift the Hands

sizeOfSprite = 0.9* S.PTB.Width / 2;

LeftHand. ReScale( sizeOfSprite / LeftHand. wPx );
RightHand.ReScale( sizeOfSprite / RightHand.wPx );

LeftHand.MoveCenter ( [ (1/4)*S.PTB.Width ; S.PTB.CenterV ] );
RightHand.MoveCenter( [ (3/4)*S.PTB.Width ; S.PTB.CenterV ] );


%% Prepare display of the fingers

FingersLeftpos = [
    726 404 % 1
    454 74  % 2
    324 44  % 3
    180 132 % 4
    32 294  % 5
    ];

fingers_color = [255 0 0 255];

LeftFingers = Fingers(FingersLeftpos, fingers_color);
RightFingers = Fingers(FingersLeftpos, fingers_color);

LeftFingers.LinkToHand(LeftHand);
RightFingers.LinkToHand(RightHand);

RightFingers.FlipLR;

LeftFingers.UpdatePos;
RightFingers.UpdatePos;
