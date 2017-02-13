function LinkToWindowPtr( obj, wPtr )

try
    Screen('GetWindowInfo',wPtr);
    obj.wPtr = wPtr;
catch err
    rethrow(err)
end

end
