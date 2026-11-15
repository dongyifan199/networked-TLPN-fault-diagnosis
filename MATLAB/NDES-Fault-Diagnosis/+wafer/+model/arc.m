function G=arc(G,t,pre,post)
% Arc lists have unit weights; repeated entries are supported.
for j=pre(:)',G.Pre(j,t)=G.Pre(j,t)+1;end
for j=post(:)',G.Post(j,t)=G.Post(j,t)+1;end
end

