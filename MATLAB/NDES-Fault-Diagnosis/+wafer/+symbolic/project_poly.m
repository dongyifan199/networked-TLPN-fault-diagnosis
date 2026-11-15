function Q=project_poly(P,keep,opts)
% Exact symbolic projection with adaptive variable elimination.  All
% inequalities remain in the firing-delay variables; no time discretization
% or sampling is used.  Strict inequalities are preserved throughout.
Q=wafer.symbolic.prune_poly(P,opts);
cols=1:size(Q.A,2);
keep=sort(keep(:)');
while ~isequal(cols,keep)
    positions=find(~ismember(cols,keep));
    if isempty(positions),break;end
    score=inf(size(positions));
    for j=1:numel(positions)
        a=Q.A(:,positions(j));
        np=nnz(a>opts.numericTolerance);
        nn=nnz(a< -opts.numericTolerance);
        nz=numel(a)-np-nn;
        if np==0 || nn==0
            score(j)=nz;
        else
            score(j)=np*nn+nz;
        end
    end
    [~,best]=min(score);
    k=positions(best);
    Q=wafer.symbolic.fm_drop(Q,k,opts);
    cols(k)=[];
end
if ~isequal(cols,keep)
    error('Projection column tracking error.');
end
Q=wafer.symbolic.prune_poly(Q,opts);
end

