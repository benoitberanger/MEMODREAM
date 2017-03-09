function [ SequenceHighLow ] = RandomizeHighLow ( NrHighLow )

iter = 0;
maxiter = 1000;

while iter < maxiter
    
    iter = iter + 1;
    
    SequenceHighLow = Shuffle([zeros(1,NrHighLow) ones(1,NrHighLow)]);
    SequenceHighLow_str = regexprep(num2str(SequenceHighLow),' ','');
    
    % maximum 3x(0) or 3x(1) in a row, max 2x(01) or 2x(10) in a row
    if ~(any(regexp(SequenceHighLow_str,'0000')) || any(regexp(SequenceHighLow_str,'1111')) || any(regexp(SequenceHighLow_str,'010101')) || any(regexp(SequenceHighLow_str,'101010')))
        break
    end
    
end

if iter >= maxiter
    error('randomizer problem : maxiter reached')
end


end
