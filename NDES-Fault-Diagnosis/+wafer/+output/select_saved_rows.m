function [Tsel,indices]=select_saved_rows(T,records,opts)
% Select compact report rows from existing complete experimental records.
if numel(records)~=height(T)
    error('Number of saved records does not match table height.');
end
indices=[];
models=unique([T.n T.m],'rows','stable');
for k=1:size(models,1)
    n=models(k,1);
    m=models(k,2);
    chosen=wafer.config.select_scenarios(opts,n,m);
    for j=1:numel(chosen)
        for i=1:numel(records)
            if records{i}.n==n && records{i}.m==m && ...
                    strcmp(records{i}.profile,chosen{j})
                indices(end+1)=i; %#ok<AGROW>
                break;
            end
        end
    end
end
indices=sort(indices);
Tsel=T(indices,:);
end
