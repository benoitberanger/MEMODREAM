function LinkToHand( obj , handPtr )

assert( isa(handPtr,'Hand') , 'handPtr must be a Hand object' )

obj.handPtr  = handPtr;
obj.flipedLR = false; % to initilize this variable

end
