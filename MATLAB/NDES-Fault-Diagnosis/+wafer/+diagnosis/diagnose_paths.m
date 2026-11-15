function [verdict,info]=diagnose_paths(G,S,A,R,opts)
% Explore initial-to-marked paths, and check constraints (a1)--(a3).
% Each path stores a separate symbolic firing delay for each
% transition occurrence, including paths through merged classes.
N=numel(R.contexts);
adj=cell(N,1);
for i=1:numel(R.edges)
    src=R.edges(i).src;
    adj{src}(end+1)=i; %#ok<AGROW>
end
st.cid=1;st.M=G.M0;st.q=A.initial;
st.P=wafer.symbolic.empty_poly(0);st.start=zeros(numel(G.tname),1);
E=wafer.model.enabled(G,st.M);st.start(E)=1;
st.events=struct('step',{},'channel',{},'matched',{},'arrival',{});
st.lastObservable=0;st.fault=false;st.depth=0;
st.trace=zeros(1,0);
STACK={st};seenF=false;seenN=false;
info.checked=0;info.feasible=0;info.expanded=0;
info.exhaustive=false;info.earlyU=false;
info.faultWitness=[];info.normalWitness=[];
while ~isempty(STACK)
    cur=STACK{end};STACK(end)=[];
    info.expanded=info.expanded+1;
    if info.expanded>opts.maxDiagnosisPaths
        error('Diagnosis path limit reached; verdict is not established.');
    end
    node=R.nodes(R.contexts(cur.cid).node);
    if node.marked && cur.lastObservable>0
        info.checked=info.checked+1;
        P=wafer.diagnosis.terminal_constraints(cur,A,S);
        if wafer.symbolic.check_poly(P,opts)
            info.feasible=info.feasible+1;
            if cur.fault && ~seenF
                seenF=true;info.faultWitness=cur.trace;
            elseif ~cur.fault && ~seenN
                seenN=true;info.normalWitness=cur.trace;
            end
            if seenF && seenN
                info.earlyU=true;
                verdict='U';return;
            end
        end
    end
    if cur.depth>=opts.maxDiagnosisDepth
        if ~isempty(adj{cur.cid})
            error('Diagnosis depth limit reached; verdict is not established.');
        end
        continue;
    end
    edges=adj{cur.cid};
    for i=numel(edges):-1:1
        e=R.edges(edges(i));
        child=wafer.diagnosis.path_step(cur,e,G,A,opts);
        if isempty(child),continue;end
        if mod(child.depth,opts.lpEvery)==0
            if ~wafer.symbolic.check_poly(child.P,opts),continue;end
        end
        STACK{end+1}=child; %#ok<AGROW>
    end
end
info.exhaustive=true;
if seenN && ~seenF,verdict='N';
elseif seenF && ~seenN,verdict='F';
else,error('No feasible diagnosis path: inspect generated observation.');
end
end

