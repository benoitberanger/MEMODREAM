function r = MakeRects( obj , posSTR )

r = CenterRectOnPoint([0 0 100 100] , obj.(posSTR)(:,1) , obj.(posSTR)(:,2) )';

end

