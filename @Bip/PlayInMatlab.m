function PlayInMatlab( obj )

obj.AssertSignalReady();

player = audioplayer(obj.signal,obj.fs);
player.playblocking();
player.play();

player.delete();
clear player

end
