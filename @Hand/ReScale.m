function ReScale( obj , newFactor )

obj.scale = newFactor;
obj.rect = ScaleRect(obj.baseRect,newFactor,newFactor);
[obj.center(1),obj.center(2)] = RectCenter(obj.rect);

end

