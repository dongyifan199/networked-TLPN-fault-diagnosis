function s=format_observation(v)
str=cell(1,numel(v.arrivals));
for i=1:numel(str)
    str{i}=sprintf('(%s,%.2f)',v.labels{i},v.arrivals(i));
end
if isempty(str),s='epsilon';else,s=strjoin(str,'');end
end

