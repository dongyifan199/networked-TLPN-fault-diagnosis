function S=network_model(n,G)
S.nCH=n+1;
S.delay=zeros(n+1,2);
S.delay(1,:)=[1,25];
for i=1:n
    r=mod(i-1,3);
    S.delay(i+1,:)=[1+r,25+5*r];
end
S.labels=cell(n+1,1);
for i=1:n+1,S.labels{i}={};end
for t=1:numel(G.label)
    if G.ch(t)>0
        S.labels{G.ch(t)}{end+1}=G.label{t}; %#ok<AGROW>
    end
end
for i=1:numel(S.labels),S.labels{i}=unique(S.labels{i},'stable');end
end

