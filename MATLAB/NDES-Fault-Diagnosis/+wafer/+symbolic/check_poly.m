function ok=check_poly(P,opts)
n=size(P.A,2);
ok=wafer.symbolic.linear_feasible(P.A,P.b,P.strict,n,opts);
end

