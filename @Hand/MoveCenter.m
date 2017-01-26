function MoveCenter( obj, newCenter )

obj.center = newCenter;
obj.rect = CenterRectOnPoint(obj.rect, newCenter(1), newCenter(2));

end

