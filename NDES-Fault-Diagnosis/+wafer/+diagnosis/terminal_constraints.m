function P=terminal_constraints(cur,A,S)
P=cur.P;k=cur.depth;
qLast=cur.lastObservable;
if qLast==0,return;end
% All firings counted in this path must occur no later than the physical
% timestamp of its last observable event. Zero-delay silent firings at
% that timestamp remain admissible.
if k>qLast
    row=zeros(1,k);row(qLast+1:k)=1;
    P=wafer.symbolic.append_row(P,row,0,false);
end
% All received events have arrived by the system's observation cutoff.
for ch=1:A.nCH
    arrivals=A.arrivals{ch};
    for j=1:numel(arrivals)
        row=zeros(1,k);row(1:qLast)=-1;
        P=wafer.symbolic.append_row(P,row,-arrivals(j),false);
    end
end
% Each additional generated event has some admissible delay under which
% its arrival occurs strictly after the observation cutoff.
for i=1:numel(cur.events)
    ev=cur.events(i);
    if ev.matched,continue;end
    row=zeros(1,k);
    if ev.step<qLast
        row(ev.step+1:qLast)=1;
    end
    P=wafer.symbolic.append_row(P,row,S.delay(ev.channel,2),true);
end
end

