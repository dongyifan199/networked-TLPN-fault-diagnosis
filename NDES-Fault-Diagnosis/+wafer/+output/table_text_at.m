function s=table_text_at(T,field,k)
col=T.(field);
if iscell(col)
    s=col{k};
elseif isstring(col)
    s=char(col(k));
elseif iscategorical(col)
    s=char(col(k));
elseif ischar(col)
    s=strtrim(col(k,:));
else
    error('Unsupported text column type for %s: %s',field,class(col));
end
if isstring(s), s=char(s); end
end

