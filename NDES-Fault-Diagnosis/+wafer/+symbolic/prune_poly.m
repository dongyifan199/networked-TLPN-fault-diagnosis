function Q=prune_poly(P,opts)
% Vectorized elimination of tautologies, duplicate normals, and rows
% dominated by another row with the same normal.  Infeasible constant
% constraints are kept as an explicit contradictory row.
n=size(P.A,2);
Q=wafer.symbolic.empty_poly(n);
if isempty(P.b),return;end
A=P.A;b=P.b(:);st=logical(P.strict(:));
if size(A,1)~=numel(b)||numel(st)~=numel(b)
    error('Invalid symbolic inequality dimensions.');
end
if any(isnan(A(:)))||any(isnan(b))
    error('NaN in timing inequalities.');
end
A(abs(A)<opts.numericTolerance)=0;
if n==0
    isConst=true(size(b));
else
    isConst=all(A==0,2);
end
bad=isConst & ((st & b<=0) | (~st & b<0));
if any(bad)
    j=find(bad,1);
    Q=wafer.symbolic.append_row(Q,zeros(1,n),b(j),st(j));
    return;
end
A=A(~isConst,:);b=b(~isConst);st=st(~isConst);
if isempty(b),return;end
sc=max(abs(A),[],2);
if any(sc<=0),error('Invalid symbolic normal.');end
A=bsxfun(@rdivide,A,sc);b=b./sc;
% Sort quantized coefficient vectors to merge identical constraints.
% Retain the corresponding normalized coefficient vectors.
scale=1/max(opts.numericTolerance/100,1e-12);
quant=round(A*scale)/scale;
[~,idx]=sortrows(quant);
A=A(idx,:);quant=quant(idx,:);b=b(idx);st=st(idx);
if size(quant,1)==1
    Q=struct('A',A,'b',b,'strict',st);
    return;
end
boundary=[true;any(diff(quant,1,1)~=0,2)];
starts=find(boundary);ends=[starts(2:end)-1;numel(b)];
na=zeros(numel(starts),n);nb=zeros(numel(starts),1);ns=false(numel(starts),1);
for i=1:numel(starts)
    k=starts(i):ends(i);
    [bb,local]=min(b(k));
    j=k(local);
    na(i,:)=A(j,:);nb(i)=bb;
    ns(i)=any(st(k) & abs(b(k)-bb)<=opts.numericTolerance);
end
Q=struct('A',na,'b',nb,'strict',ns);
end

