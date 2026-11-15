function ren=variable_renaming(incoming,representative)
ren=cell(1,numel(incoming));
for i=1:numel(incoming)
    ren{i}=sprintf('%s := %s',representative{i},incoming{i});
end
end

