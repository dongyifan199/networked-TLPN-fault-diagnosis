function A=observation_automaton(v,S)
% State = vector of matched prefixes of each channel projection.
% Once the expected projection is matched, further symbols of the same
% channel remain possible as pending (not yet delivered) observations.
A.required=cell(S.nCH,1); A.arrivals=cell(S.nCH,1);
for ch=1:S.nCH
    ix=find(v.channels==ch);
    A.required{ch}=v.labels(ix);
    A.arrivals{ch}=v.arrivals(ix);
end
A.counts=cellfun(@numel,A.required)';
A.initial=zeros(1,S.nCH);
A.nCH=S.nCH;
A.v=v;
A.netDelay=S.delay;
end

