function child=path_step(cur,e,G,A,opts)
t=e.t;
if ~all(cur.M>=G.Pre(:,t)),error('Incorrect edge incidence.');end
k=cur.depth+1;child=cur;
P=cur.P;
P.A=[P.A zeros(size(P.A,1),1)];
row=zeros(1,k);row(end)=-1;
P=wafer.symbolic.append_row(P,row,0,false);
row=zeros(1,k);row(cur.start(t):k)=1;
P=wafer.symbolic.append_row(P,-row,-G.I(t,1),false);
E=wafer.model.enabled(G,cur.M);
for j=E(:)'
    if isfinite(G.I(j,2))
        row=zeros(1,k);row(cur.start(j):k)=1;
        P=wafer.symbolic.append_row(P,row,G.I(j,2),true);
    end
end
Mmid=cur.M-G.Pre(:,t);
Mnew=cur.M+G.Post(:,t)-G.Pre(:,t);
Ep=wafer.model.enabled(G,Mnew);
starts=zeros(size(cur.start));
for j=Ep(:)'
    if j==t || ~all(Mmid>=G.Pre(:,j))
        starts(j)=k+1;
    else
        starts(j)=cur.start(j);
    end
end
child.P=P;child.start=starts;
child.M=Mnew;
child.cid=e.dst;
child.depth=k;
child.fault=cur.fault || G.fault(t);
child.trace(end+1)=t;
[qnext,ok,matched]=wafer.observation.automaton_step(A,cur.q,G.ch(t),G.label{t});
if ~ok,error('Incompatible product edge.');end
child.q=qnext;
if G.ch(t)>0
    ch=G.ch(t);
    child.lastObservable=k;
    ev.step=k;ev.channel=ch;ev.matched=matched;ev.arrival=nan;
    if matched
        ix=qnext(ch);
        ev.arrival=A.arrivals{ch}(ix);
    end
    child.events(end+1)=ev;
    if matched
        ar=ev.arrival;
        lo=A.netDelay(ch,1);hi=A.netDelay(ch,2);
        row=zeros(1,k);row(:)=1;
        P=wafer.symbolic.append_row(P,row,ar-lo,false);
        P=wafer.symbolic.append_row(P,-row,hi-ar,true);
        child.P=P;
    else
        % Pending event must admit arrival after the final plant cutoff;
        % this cutoff is at least the latest received timestamp.
        newest=max(A.v.arrivals);
        du=A.netDelay(ch,2);
        row=-ones(1,k);
        child.P=wafer.symbolic.append_row(child.P,row,du-newest,true);
    end
    % A pending event must also remain pending at every later observable
    % firing time, not only at the final marked path. These are necessary
    % constraints, so a violation safely prunes the entire path prefix.
    for z=1:numel(child.events)
        pending=child.events(z);
        if pending.matched || pending.step>=k,continue;end
        row=zeros(1,k);row(pending.step+1:k)=1;
        child.P=wafer.symbolic.append_row(child.P,row,A.netDelay(pending.channel,2),true);
    end
end
if isfield(opts,'traceCheck') && opts.traceCheck
    assert(isequal(cur.M+G.Post(:,t)-G.Pre(:,t),child.M));
end
end

