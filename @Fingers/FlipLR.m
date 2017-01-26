function FlipLR( obj )

assert( obj.IsLinked() , 'use LinkToHand method before FlipLR' )

obj.flipedLR = true;

obj.basePos = [obj.handPtr.wPx - obj.basePos(:,1) , obj.basePos(:,2) ];
obj.baseRects = obj.MakeRects('basePos'); % update baseRects according to the new basePos

end
