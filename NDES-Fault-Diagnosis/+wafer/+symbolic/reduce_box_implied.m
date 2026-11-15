function Q=reduce_box_implied(P,opts)
% Delete a non-axis inequality only when independent axis bounds certify
% it strictly. A row never uses itself as a certificate.
Q=wafer.symbolic.prune_poly(P,opts);
A=Q.A;b=Q.b(:);st=logical(Q.strict(:));
[r,n]=size(A);
if r<3 || n==0,return;end
nnzrow=sum(abs(A)>opts.numericTolerance,2);
axisRows=find(nnzrow==1);
if isempty(axisRows),return;end
L=-inf(1,n);U=inf(1,n);
for ix=axisRows(:)'
    j=find(abs(A(ix,:))>opts.numericTolerance,1);
    coeff=A(ix,j);
    if coeff>0,U(j)=min(U(j),b(ix)/coeff);
    else,L(j)=max(L(j),b(ix)/coeff);end
end
margin=max(1000*opts.numericTolerance,1e-6);
remove=false(r,1);
for ix=find(nnzrow>1)'
    row=A(ix,:);
    kP=row>opts.numericTolerance;
    kN=row< -opts.numericTolerance;
    if any(~isfinite(U(kP)))||any(~isfinite(L(kN))),continue;end
    best=sum(row(kP).*U(kP))+sum(row(kN).*L(kN));
    if isfinite(best) && best < b(ix)-margin
        remove(ix)=true;
    end
end
if any(remove)
    Q.A=Q.A(~remove,:);Q.b=Q.b(~remove);Q.strict=Q.strict(~remove);
end
end

