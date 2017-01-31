function results = SequenceAnalyzer( sequence, side, duration, from, to, KL )

rawdata = KL.Data(from:to,:);

down_idx = cell2mat(rawdata(:,3));
downdata = rawdata(find(down_idx),:); %#ok<*FNDSB>

side_idx = regexp(downdata(:,1),side(1));
side_idx = ~cellfun(@isempty,side_idx);
side_idx = find(side_idx);
sidedata = downdata(side_idx,:);

seq = sidedata(:,1);
seq = cell2mat(seq);
seq = seq(:,2)';

results       = struct;
results.N     = length(seq);          % number of clicks
results.speed = length(seq)/duration; % clicks per seconds


completSeq = regexp(seq,sequence);
results.completSeq = length(completSeq);

end
