function ok=linear_feasible(A,b,strict,n,opts)
% Strict feasibility via a common positive slack variable epsilon.
% epsilon is maximized in [0,1]; no strict inequality is relaxed to <=.
if size(A,2)~=n,error('LP dimension mismatch.');end
if n==0
    ok=all((~strict(:) & b>=0) | (strict(:) & b>0));
    return;
end
if isempty(b),ok=true;return;end
A=[A double(strict(:))];
f=[zeros(n,1);-1];
lb=[-inf(n,1);0];ub=[inf(n,1);1];
[sol,~,exitflag]=linprog(f,A,b,[],[],lb,ub,opts.lpOptions);
if exitflag==1
    ok=sol(end)>opts.strictTolerance;
elseif exitflag==-2
    ok=false;
else
    error('Linear feasibility solver returned exitflag=%d.',exitflag);
end
end

