function Q=reduce_core_implied(P,opts)
% A sufficient LP certificate using a SMALL SUBSET of constraints.
% If a candidate is implied by the subset, it is implied by the whole set.
% Unproved rows are retained; the algorithm never guesses redundancy.
Q=wafer.symbolic.prune_poly(P,opts);
r=numel(Q.b);n=size(Q.A,2);
if r<=opts.FMRedundancyInputCap
    Q=wafer.symbolic.reduce_redundant_rows(Q,opts);return;
end
if r<opts.FMAdaptiveTrigger || n==0,return;end
% Axis constraints and relatively tight normalized bounds form a cheap core.
coefCount=sum(abs(Q.A)>opts.numericTolerance,2);
axis=find(coefCount==1);
[~,ib]=sort(Q.b,'ascend');
core=unique([axis(:);ib(1:min(opts.FMCoreSize,numel(ib)))],'stable');
if numel(core)<n+1,return;end
% Examine newest / loose rows only; bound LP work per call.
candidates=unique(round(linspace(1,r,min(opts.FMAdaptiveChecks,r))));
margin=max(1000*opts.numericTolerance,1e-6);
remove=false(r,1);
for j=candidates(:)'
    if any(core==j),continue;end
    try
        [~,value,flag]=linprog(-Q.A(j,:)',Q.A(core,:),Q.b(core),[],[],...
            -inf(n,1),inf(n,1),opts.lpOptions);
    catch
        continue;
    end
    if flag==1 && isfinite(value) && -value < Q.b(j)-margin
        remove(j)=true;
    end
end
if any(remove)
    Q.A=Q.A(~remove,:);Q.b=Q.b(~remove);Q.strict=Q.strict(~remove);
end
end

