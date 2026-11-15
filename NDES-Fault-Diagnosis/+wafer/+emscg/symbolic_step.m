function [s,ok]=symbolic_step(G,c,t,opts)
% Theta uses symbolic firing delay variables, rather than a clock zone.
% Firing condition: delta >= 0, age_t+delta >= L_t,
% and age_j+delta < U_j for every enabled transition j.
Mnew=c.M+G.Post(:,t)-G.Pre(:,t);
E=wafer.model.enabled(G,c.M);Ep=wafer.model.enabled(G,Mnew);
n=size(c.age,2);d=n+1;
ages=[c.age zeros(size(c.age,1),1)];
P=wafer.symbolic.empty_poly(d);
P.A=[c.P.A zeros(size(c.P.A,1),1)];
P.b=c.P.b;P.strict=c.P.strict;
row=zeros(1,d);row(d)=-1;P=wafer.symbolic.append_row(P,row,0,false);
row=ages(t,:);row(end)=row(end)+1;
P=wafer.symbolic.append_row(P,-row,-G.I(t,1),false);
for j=E(:)'
    if isfinite(G.I(j,2))
        row=ages(j,:);row(end)=row(end)+1;
        P=wafer.symbolic.append_row(P,row,G.I(j,2),true);
    end
end
P=wafer.symbolic.prune_poly(P,opts);
ok=wafer.symbolic.check_poly(P,opts);
if ~ok,s=[];return;end
Mmid=c.M-G.Pre(:,t);
newAge=zeros(size(ages));
for j=Ep(:)'
    if j==t || ~all(Mmid>=G.Pre(:,j))
        newAge(j,:)=0;
    else
        newAge(j,:)=ages(j,:);
        newAge(j,end)=newAge(j,end)+1;
    end
end
keep=find(any(abs(newAge)>opts.numericTolerance,1));
s.M=Mnew;s.q=c.q;
s.age=newAge(:,keep);
v=[c.vars {sprintf('d%d',n+1)}];
s.vars=v(keep);
s.P=wafer.symbolic.project_poly(P,keep,opts);
end

