function [ SequenceHighLow ] = RandomizeHighLow ( NrHighLow )

iter = 0;
maxiter = 1000;

while iter < maxiter
    
    iter = iter + 1;
    
    SequenceHighLow = Shuffle([zeros(1,NrHighLow) ones(1,NrHighLow)]);
    SequenceHighLow_str = regexprep(num2str(SequenceHighLow),' ','');
    
    if ~(any(regexp(SequenceHighLow_str,'0000')) || any(regexp(SequenceHighLow_str,'1111'))) % maximum 3 in a row
        break
    end
    
end

if iter >= maxiter
    error('randomizer problem')
end


end

