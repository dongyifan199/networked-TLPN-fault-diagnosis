function txt=age_expression(coef,vars)
parts={};
for i=1:numel(coef)
    if coef(i)==0,continue;end
    if coef(i)==1
        parts{end+1}=vars{i}; %#ok<AGROW>
    else
        parts{end+1}=sprintf('%g*%s',coef(i),vars{i}); %#ok<AGROW>
    end
end
if isempty(parts),txt='0';else,txt=strjoin(parts,' + ');end
end

