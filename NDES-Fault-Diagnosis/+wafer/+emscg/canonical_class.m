function [s,perm]=canonical_class(s)
n=size(s.age,2);
if n==0,perm=[];return;end
[~,perm]=sortrows(s.age');
s.age=s.age(:,perm);
s.vars=s.vars(perm);
s.P.A=s.P.A(:,perm);
end

