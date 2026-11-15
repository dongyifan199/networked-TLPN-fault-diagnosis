function Q=fm_drop(P,k,opts)
% Eliminate one symbolic delay by combining its positive and negative
% coefficient rows. Matrix and vector shapes are enforced explicitly.
P=wafer.symbolic.prune_poly(P,opts);
A=P.A;
b=P.b(:);
s=logical(P.strict(:));
n=size(A,2);
if k<1 || k>n, error('Invalid symbolic projection column.'); end
if size(A,1)~=numel(b) || numel(b)~=numel(s)
    error('Invalid symbolic inequality array shapes before projection.');
end
pos=find(A(:,k)>opts.numericTolerance);
neg=find(A(:,k)<-opts.numericTolerance);
zero=find(abs(A(:,k))<=opts.numericTolerance);
raw=double(numel(pos))*double(numel(neg))+double(numel(zero));
if raw>opts.FMReductionTrigger && size(A,1)<=opts.FMRedundancyInputCap
    P=wafer.symbolic.reduce_redundant_rows(P,opts);
    P=wafer.symbolic.prune_poly(P,opts);
    A=P.A;b=P.b(:);s=logical(P.strict(:));
    pos=find(A(:,k)>opts.numericTolerance);
    neg=find(A(:,k)<-opts.numericTolerance);
    zero=find(abs(A(:,k))<=opts.numericTolerance);
end
Ao=reshape(A(zero,:),numel(zero),n);
bo=reshape(b(zero),[],1);
so=reshape(s(zero),[],1);
if ~isempty(pos) && ~isempty(neg)
    pp=A(pos,k);nnv=-A(neg,k);
    Ap=bsxfun(@rdivide,A(pos,:),pp);
    An=bsxfun(@rdivide,A(neg,:),nnv);
    bp=b(pos)./pp;bn=b(neg)./nnv;
    sp=s(pos);sn=s(neg);
    npos=numel(pos);nneg=numel(neg);
    blockSize=max(1,floor(opts.FMChunkRows/max(1,nneg)));
    for first=1:blockSize:npos
        idx=first:min(npos,first+blockSize-1);
        ii=kron(idx(:),ones(nneg,1));
        jj=repmat((1:nneg)',numel(idx),1);
        rr=numel(ii);
        ca=Ap(ii,:)+An(jj,:);
        cb=bp(ii)+bn(jj);
        cs=sp(ii)|sn(jj);
        % Validate coefficient, bound and strictness dimensions.
        if size(ca,1)~=rr || size(ca,2)~=n || numel(cb)~=rr || numel(cs)~=rr
            error('Projection block dimensions: A=%dx%d, b=%d, strict=%d, expected=%dx%d.',...
                size(ca,1),size(ca,2),numel(cb),numel(cs),rr,n);
        end
        ca(:,k)=0;
        % Append the projected coefficient and bound blocks.
        last=size(Ao,1);
        Ao(last+(1:rr),1:n)=reshape(ca,rr,n);
        bo(last+(1:rr),1)=reshape(cb,rr,1);
        so(last+(1:rr),1)=logical(reshape(cs,rr,1));
        if size(Ao,1)~=numel(bo) || numel(bo)~=numel(so)
            error('Projection accumulated rows have inconsistent dimensions.');
        end
        if numel(bo)>opts.FMChunkRows+opts.FMReductionTrigger
            tmp=wafer.symbolic.prune_poly(struct('A',Ao,'b',bo,'strict',so),opts);
            Ao=tmp.A;bo=tmp.b(:);so=logical(tmp.strict(:));
        end
        if numel(bo)>opts.FMAdaptiveTrigger && ...
                (first==1 || mod(first-1,max(1,blockSize*4))==0)
            tmp=struct('A',Ao,'b',bo,'strict',so);
            tmp=wafer.symbolic.reduce_box_implied(tmp,opts);
            if numel(tmp.b)>opts.FMAdaptiveTrigger
                tmp=wafer.symbolic.reduce_core_implied(tmp,opts);
            end
            Ao=tmp.A;bo=tmp.b(:);so=logical(tmp.strict(:));
        end
        if numel(bo)>opts.maxFMRows
            tmp=wafer.symbolic.reduce_box_implied(struct('A',Ao,'b',bo,'strict',so),opts);
            tmp=wafer.symbolic.reduce_core_implied(tmp,opts);
            if size(tmp.A,1)<=opts.FMRedundancyInputCap
                tmp=wafer.symbolic.reduce_redundant_rows(tmp,opts);
            end
            Ao=tmp.A;bo=tmp.b(:);so=logical(tmp.strict(:));
            if numel(bo)>opts.maxFMRows
                error(['Symbolic projection exceeds the retained-row limit ',...
                    '(%d rows; column %d; positive %d; negative %d). ',...
                    'Results are incomplete.'],numel(bo),k,npos,nneg);
            end
        end
    end
end
if size(Ao,2)~=n || size(Ao,1)~=numel(bo) || numel(bo)~=numel(so)
    error('Projection output has inconsistent sizes before dropping variable.');
end
Ao(:,k)=[];
Q=wafer.symbolic.prune_poly(struct('A',Ao,'b',bo(:),'strict',logical(so(:))),opts);
if numel(Q.b)>opts.maxFMRows
    error('Symbolic projection exceeds the retained-row limit (%d).',numel(Q.b));
end
end

