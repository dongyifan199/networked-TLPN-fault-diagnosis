function view=presentation_table(T)
% Preserve raw measured times in T; format time columns for reporting.
view=T;
if isempty(T)
    return;
end
n=height(T);
tEM=cell(n,1);
tD=cell(n,1);
for i=1:n
    tEM{i}=wafer.output.format_seconds(T.T_EM(i));
    tD{i}=wafer.output.format_seconds(T.T_D(i));
end
view.T_EM=string(tEM);
view.T_D=string(tD);
end
