function G=wafer_model(n,m)
% Parameterized TLPN of the wafer-processing system in the figure.
% The nominal plant has 4*n+5 places and 4*n+4 transitions.
% One unobservable fault transition is added to the loadlock and each module.
assert(n>=1 && m>=1 && n==floor(n) && m==floor(m));
G.n=n;G.m=m;
% Loadlock places: p04, p01, p02, p03. Shared robot place: pr.
G.raw=1;G.loadHold=2;G.loadReady=3;G.returnPlace=4;G.robot=5;
G.mod=@(i,j) 5+4*(i-1)+j;
Np=4*n+5; Nt=5*n+5;
G.Pre=zeros(Np,Nt);G.Post=zeros(Np,Nt);
G.I=zeros(Nt,2);G.label=repmat({''},Nt,1);
G.tname=repmat({''},Nt,1);G.ch=zeros(Nt,1);
G.fault=false(Nt,1);
G.M0=zeros(Np,1);G.M0(G.raw)=m;G.M0(G.robot)=1;

% Loadlock: pr -> t01 -> p01 -> {t02,t05} -> p02;
% p02 + p04 -> t03 -> p13; p03 -> t04 -> p04 + pr.
G=wafer.model.arc(G,1,G.robot,G.loadHold);
G=wafer.model.event(G,1,'t01','a',1,[1,30],false);
G=wafer.model.arc(G,2,G.loadHold,G.loadReady);
G=wafer.model.event(G,2,'t02','',0,[2,5],false);
G=wafer.model.arc(G,3,[G.loadReady,G.raw],G.mod(1,3));
G=wafer.model.event(G,3,'t03','',0,[1,4],false);
G=wafer.model.arc(G,4,G.returnPlace,[G.raw,G.robot]);
G=wafer.model.event(G,4,'t04','d',1,[2,8],false);

for i=1:n
    k=4+4*(i-1);
    % pr -> ti1 -> pi1 -> {ti2,ti5} -> pi2.
    G=wafer.model.arc(G,k+1,G.robot,G.mod(i,1));
    G=wafer.model.event(G,k+1,sprintf('t%d1',i),'',0,...
        [1+.05*i,30+.05*i],false);
    G=wafer.model.arc(G,k+2,G.mod(i,1),G.mod(i,2));
    G=wafer.model.event(G,k+2,sprintf('t%d2',i),'',0,...
        [18+.2*i,28+.2*i],false);
    % pi2 + pi4 -> ti3 -> p(i+1)3; tn3 -> p03.
    if i<n
        nextPlace=G.mod(i+1,3);
    else
        nextPlace=G.returnPlace;
    end
    G=wafer.model.arc(G,k+3,[G.mod(i,2),G.mod(i,4)],nextPlace);
    G=wafer.model.event(G,k+3,sprintf('t%d3',i),'',0,...
        [0,6+.05*i],false);
    % pi3 -> ti4 -> pi4 + pr.
    G=wafer.model.arc(G,k+4,G.mod(i,3),[G.mod(i,4),G.robot]);
    G=wafer.model.event(G,k+4,sprintf('t%d4',i),sprintf('b%d',i),i+1,...
        [2+.05*i,8+.05*i],false);
end

% Unobservable alternatives have the same input/output places as
% the corresponding nominal transitions.
k=4*n+5;
G=wafer.model.arc(G,k,G.loadHold,G.loadReady);
G=wafer.model.event(G,k,'t05','',0,[1,3.7],true);
for i=1:n
    k=4*n+5+i;
    G=wafer.model.arc(G,k,G.mod(i,1),G.mod(i,2));
    G=wafer.model.event(G,k,sprintf('t%d5',i),'',0,...
        [16+.2*i,22.2+.2*i],true);
end
assert(isequal(size(G.Pre),[4*n+5,5*n+5]));
assert(isequal(size(G.Post),[4*n+5,5*n+5]));
assert(nnz(G.fault)==n+1);
end
