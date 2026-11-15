function [R,cid,isNew,renaming]=add_context(R,s,A,opts)
[s,~]=wafer.emscg.canonical_class(s);
n=size(s.age,2);
if n>opts.maxActiveVars
    error('Number of active symbolic variables exceeds maxActiveVars.');
end
key=[wafer.emscg.vector_key(s.M) ';' wafer.emscg.vector_key(s.q) ';' mat2str(s.age,9)];
if isKey(R.nodeIndex,key)
    j=R.nodeIndex(key);
    R.stats.merges=R.stats.merges+1;
else
    if numel(R.nodes)>=opts.maxGraphNodes
        error('EM-SCG node limit reached; results are not complete.');
    end
    j=numel(R.nodes)+1;
    R.nodeIndex(key)=j;
    R.nodes(j)=struct('M',s.M,'q',s.q,'age',s.age,...
        'vars',{s.vars},'Theta',{wafer.emscg.class_theta(R.net,s)},...
        'contexts',[],'marked',all(s.q==A.counts));
end
pkey=wafer.emscg.poly_key(s.P,opts);
ckey=[key '::' pkey];
if isKey(R.ctxIndex,ckey)
    cid=R.ctxIndex(ckey);isNew=false;
    renaming=wafer.emscg.variable_renaming(s.vars,R.nodes(j).vars);
    return;
end
if numel(R.contexts)>=opts.maxContexts
    error('EM-SCG context limit reached; results are not complete.');
end
cid=numel(R.contexts)+1;
R.ctxIndex(ckey)=cid;
R.contexts(cid)=struct('node',j,'M',s.M,'q',s.q,'age',s.age,...
    'vars',{s.vars},'Theta',{wafer.emscg.class_theta(R.net,s)},...
    'P',s.P,'expandedU',false,'expandedO',false);
R.nodes(j).contexts(end+1)=cid;
renaming=wafer.emscg.variable_renaming(s.vars,R.nodes(j).vars);
isNew=true;
end

