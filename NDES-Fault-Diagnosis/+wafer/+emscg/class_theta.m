function theta=class_theta(G,s)
E=wafer.model.enabled(G,s.M);
theta=cell(1,numel(E));
for i=1:numel(E)
    t=E(i);
    a=wafer.emscg.age_expression(s.age(t,:),s.vars);
    theta{i}=sprintf('%s : max(0, %g-(%s)) <= theta < %g-(%s)',...
        G.tname{t},G.I(t,1),a,G.I(t,2),a);
end
end

