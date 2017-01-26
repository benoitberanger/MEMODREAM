function Draw( obj , fingers )

assert(~isempty(fingers), 'fingers number must not be empty, or PTB will draw weird stuff')

Screen('FillOval', obj.handPtr.wPtr , obj.color(:,fingers) , obj.rects(:,fingers) );

end
