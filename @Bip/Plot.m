function Plot( obj )

obj.AssertSignalReady();

figure
plot(obj.time, obj.signal)
axis tight
xlabel('time (s)')
ylabel('signal')

end
