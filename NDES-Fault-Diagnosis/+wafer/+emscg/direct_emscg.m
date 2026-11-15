function R=direct_emscg(G,A,opts)
% Construct the product directly, without building the plant MSCG first.
% For each OPEN seed: unobservable closure, then observable DFA steps.
R.nodes=struct('M',{},'q',{},'age',{},'vars',{},'Theta',{},'contexts',{},'marked',{});
R.contexts=struct('node',{},'M',{},'q',{},'age',{},'vars',{},'Theta',{},...
    'P',{},'expandedU',{},'expandedO',{});
R.edges=struct('src',{},'dst',{},'t',{},'name',{},'label',{},...
    'Delta',{},'lower',{},'upper',{},'renaming',{});
R.nodeIndex=containers.Map('KeyType','char','ValueType','double');
R.ctxIndex=containers.Map('KeyType','char','ValueType','double');
R.stats=struct('merges',0,'contexts',0);
R.net=G;
seed.M=G.M0;seed.q=A.initial;seed.age=zeros(numel(G.tname),0);
seed.vars={};seed.P=wafer.symbolic.empty_poly(0);
[R,first]=wafer.emscg.add_context(R,seed,A,opts);
OPEN=first;
while ~isempty(OPEN)
    root=OPEN(1);OPEN(1)=[];
    closureQueue=root;
    closureMembers=zeros(1,0);
    % Unobservable closure at the fixed automaton state.
    while ~isempty(closureQueue)
        cid=closureQueue(1);closureQueue(1)=[];
        if R.contexts(cid).expandedU,continue;end
        R.contexts(cid).expandedU=true;
        closureMembers(end+1)=cid; %#ok<AGROW>
        c=R.contexts(cid);
        E=wafer.model.enabled(G,c.M);
        for t=E(G.ch(E)==0)
            [s,ok]=wafer.emscg.symbolic_step(G,c,t,opts);
            if ~ok,continue;end
            s.q=c.q;
            [R,dst,isNew,renaming]=wafer.emscg.add_context(R,s,A,opts);
            R=wafer.emscg.append_graph_edge(R,cid,dst,t,G,c,renaming,opts);
            if isNew,closureQueue(end+1)=dst;end %#ok<AGROW>
        end
    end
    % Observable transitions from every context of this closure.
    for cid=closureMembers
        if R.contexts(cid).expandedO,continue;end
        R.contexts(cid).expandedO=true;
        c=R.contexts(cid);
        E=wafer.model.enabled(G,c.M);
        for t=E(G.ch(E)~=0)
            [qnext,allow]=wafer.observation.automaton_step(A,c.q,G.ch(t),G.label{t});
            if ~allow,continue;end
            [s,ok]=wafer.emscg.symbolic_step(G,c,t,opts);
            if ~ok,continue;end
            s.q=qnext;
            [R,dst,isNew,renaming]=wafer.emscg.add_context(R,s,A,opts);
            R=wafer.emscg.append_graph_edge(R,cid,dst,t,G,c,renaming,opts);
            if isNew,OPEN(end+1)=dst;end %#ok<AGROW>
        end
    end
end
R.stats.contexts=numel(R.contexts);
R=rmfield(R,{'nodeIndex','ctxIndex'});
end

