function v=project_arrivals(physical,S,n,m,profile,caseNo)
% Fixed delay within each channel ensures FIFO for all transmitted labels.
cutoff=physical(end).time;
arrival=zeros(1,numel(physical));
for i=1:numel(physical)
    ch=physical(i).channel;
    lo=S.delay(ch,1);hi=S.delay(ch,2);
    if strcmp(profile,'fault_early')
        fraction=0.001;         % early arrivals, useful for F candidates
    elseif strcmp(profile,'normal') || strcmp(profile,'deep')
        fraction=0.09+0.012*mod(ch+caseNo,3);
    else
        % Short-prefix observations retain the loadlock labels while
        % module labels can still be in transit at the cutoff.
        if ch==1
            fraction=0.03;
        else
            fraction=0.31+0.02*mod(ch,3);
        end
    end
    arrival(i)=physical(i).time+lo+fraction*(hi-lo);
end
keep=find(arrival<=cutoff+1e-10);
[ordered,ord]=sort(arrival(keep));keep=keep(ord);
v.labels={physical(keep).label};
% The printed observation is EXACTLY the one passed to the LP.
v.arrivals=round(ordered,2);
v.channels=[physical(keep).channel];
v.times=[physical(keep).time];
v.n=n;v.m=m;v.cutoff=cutoff;
for ch=1:S.nCH
    ix=find(v.channels==ch);
    assert(all(diff(v.arrivals(ix))>=-1e-10),'Generated FIFO violation.');
end
end

