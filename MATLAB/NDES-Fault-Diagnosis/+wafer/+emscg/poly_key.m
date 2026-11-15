function str=poly_key(P,opts)
P=wafer.symbolic.prune_poly(P,opts);
if isempty(P.b),str=sprintf('empty_%d',size(P.A,2));return;end
V=[round(P.A*1e9)/1e9,round(P.b*1e9)/1e9,double(P.strict)];
V=sortrows(V);
str=mat2str(V,9);
end

