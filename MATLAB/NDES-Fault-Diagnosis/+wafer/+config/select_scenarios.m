function selected=select_scenarios(opts,n,m)
% For every wafer model, retain the fault_early observation and one
% reproducibly selected observation from normal or prefix.
selected=opts.scenarios;
if strcmp(opts.selectionMode,'full')
    return;
end
first=selected(strcmp(selected,'fault_early'));
candidates=selected(ismember(selected,{'normal','prefix'}));
if ~isempty(candidates)
    seed=mod(double(opts.selectionSeed)+1009*double(n)+9176*double(m),2^32-1);
    stream=RandStream('mt19937ar','Seed',seed);
    choice=randi(stream,numel(candidates));
    selected=[first candidates(choice)];
else
    selected=first;
end
end
