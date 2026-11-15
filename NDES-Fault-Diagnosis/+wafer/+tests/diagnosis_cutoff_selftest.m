function diagnosis_cutoff_selftest()
% A silent transition delayed beyond the last observable event is
% outside the observation horizon.
A.nCH=1;A.arrivals={5};
S.delay=[1 10];
cur.P=wafer.symbolic.empty_poly(2);
cur.depth=2;cur.lastObservable=1;
cur.events=struct('step',1,'channel',1,'matched',true,'arrival',5);
P=wafer.diagnosis.terminal_constraints(cur,A,S);
assert(any(all(P.A==[0 1],2) & P.b==0 & ~P.strict));
end

