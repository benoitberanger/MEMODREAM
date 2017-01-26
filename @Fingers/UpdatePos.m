function UpdatePos( obj )

assert( obj.IsLinked() , 'use LinkToHand method before UpdatePos')

% Update scale
obj.scale = obj.handPtr.scale;

% handDisplacement is the displacement between the baseRect of Hand and the
% newRect of Hand TOP LEFT corner, not the centers displacement.
handDisplacement = [obj.handPtr.rect(1)-obj.handPtr.baseRect(1) , obj.handPtr.rect(2)-obj.handPtr.baseRect(2)];

% Scale the basic rectangles according the linked' Hand scale
obj.rects = ScaleRect(obj.baseRects',obj.scale,obj.scale)';

% Then apply the displacement for top left corner
obj.rects = OffsetRect(obj.rects,handDisplacement(1),handDisplacement(2));

end
