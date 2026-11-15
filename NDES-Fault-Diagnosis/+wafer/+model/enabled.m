function E=enabled(G,M)
E=find(all(bsxfun(@ge,M(:),G.Pre),1));
end

