function validate_timed_trace(G,trace,deltas)
% Replay the generated execution using the physical enabling-memory rules.
M=G.M0;Nt=numel(G.tname);age=nan(Nt,1);
E=wafer.model.enabled(G,M);age(E)=0;
for k=1:numel(trace)
    t=trace(k);d=deltas(k);
    E=wafer.model.enabled(G,M);
    assert(any(E==t) && isfinite(d) && d>=0);
    assert(age(t)+d>=G.I(t,1)-1e-8);
    assert(all(age(E)+d<G.I(E,2)+1e-8));
    age(E)=age(E)+d;
    mid=M-G.Pre(:,t);
    M=M+G.Post(:,t)-G.Pre(:,t);
    Ep=wafer.model.enabled(G,M);
    newAge=nan(Nt,1);
    for j=Ep(:)'
        if j==t || ~any(E==j) || ~all(mid>=G.Pre(:,j))
            newAge(j)=0;
        else
            newAge(j)=age(j);
        end
    end
    age=newAge;
end
end

