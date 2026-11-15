function G=event(G,t,name,label,ch,intv,isfault)
G.tname{t}=name;G.label{t}=label;
G.ch(t)=ch;G.I(t,:)=intv;G.fault(t)=isfault;
end

