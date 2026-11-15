function P=append_row(P,a,b,isStrict)
P.A(end+1,:)=reshape(a,1,[]);
P.b(end+1,1)=b;
P.strict(end+1,1)=logical(isStrict);
end

