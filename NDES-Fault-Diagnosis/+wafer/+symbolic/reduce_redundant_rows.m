function Q=reduce_redundant_rows(P,opts)
% Optional LP-certified redundancy removal on small constraint systems.
% A row is removed only when its inequality follows with a *strict*
% numerical margin from all the other (relaxed) inequalities.
Q=wafer.symbolic.prune_poly(P,opts);
r=numel(Q.b);
if r<3||r>opts.FMRedundancyInputCap,return;end
n=size(Q.A,2);
if n==0,return;end
keep=true(r,1);
margin=max(100*opts.numericTolerance,1e-8);
for i=r:-1:1
    if ~keep(i),continue;end
    rest=find(keep);rest(rest==i)=[];
    if isempty(rest),continue;end
    a=Q.A(i,:)';
    try
        [~,val,flag]=linprog(-a,Q.A(rest,:),Q.b(rest),[],[],...
            -inf(n,1),inf(n,1),opts.lpOptions);
    catch
        continue;
    end
    % val=-max(a*x). We do NOT remove boundary-touching inequalities.
    if flag==1 && isfinite(val) && -val < Q.b(i)-margin
        keep(i)=false;
    end
end
Q.A=Q.A(keep,:);Q.b=Q.b(keep);Q.strict=Q.strict(keep);
end

