function [lo,hi]=edge_bounds(G,c,t)
lo=sprintf('max(0,%g-(%s))',G.I(t,1),...
    wafer.emscg.age_expression(c.age(t,:),c.vars));
E=wafer.model.enabled(G,c.M);
upper={};
for j=E(:)'
    if isfinite(G.I(j,2))
        upper{end+1}=sprintf('%g-(%s)',G.I(j,2),...
            wafer.emscg.age_expression(c.age(j,:),c.vars)); %#ok<AGROW>
    end
end
if isempty(upper),hi='Inf';else,hi=['min(' strjoin(upper,',') ')'];end
end

