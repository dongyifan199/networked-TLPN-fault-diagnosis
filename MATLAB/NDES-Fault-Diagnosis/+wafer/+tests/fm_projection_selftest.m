function fm_projection_selftest(opts)
% Exercise empty/singleton/multirow projection and open time bounds.
cases=cell(4,1);
cases{1}=struct('A',[1 -1;-1 -1;0 1;0 -1],...
    'b',[3;0;2;0],'strict',logical([0;0;1;0]));
cases{2}=struct('A',[1 1; -1 1; 0 2;0 -2],...
    'b',[5;4;7;8],'strict',logical([0;1;0;0]));
cases{3}=struct('A',[1; -1],...
    'b',[1;0],'strict',logical([1;0]));
cases{4}=struct('A',zeros(1,0),...
    'b',1,'strict',false);
for i=1:3
    P=cases{i};
    Q=wafer.symbolic.fm_drop(P,1,opts);
    assert(size(Q.A,2)==size(P.A,2)-1);
    assert(size(Q.A,1)==numel(Q.b));
    assert(numel(Q.strict)==numel(Q.b));
end
assert(wafer.symbolic.check_poly(cases{4},opts));
% Confirm that a provably implied mixed inequality can be removed,
% including when all bounding constraints have open upper limits.
B=struct('A',[1 0;-1 0;0 1;0 -1;1 1],...
    'b',[1;0;2;0;4],'strict',logical([1;0;1;0;1]));
QB=wafer.symbolic.reduce_box_implied(B,opts);
assert(numel(QB.b)==4);
% Construct a batch that produces many distinct candidate rows.
ng=25;
A=[ones(ng,1), (1:ng)'; -ones(ng,1), -(1:ng)'];
b=[(101:100+ng)';(101:100+ng)'];
s=false(2*ng,1);s(1)=true;
P=struct('A',A,'b',b,'strict',s);
Q=wafer.symbolic.fm_drop(P,1,opts);
assert(size(Q.A,2)==1 && size(Q.A,1)==numel(Q.b));
assert(numel(Q.strict)==numel(Q.b));
% Compare quantified feasibility with sampled retained variable values.
P=cases{1};Q=wafer.symbolic.fm_drop(P,1,opts);
for x=[-3,-1,0,1,2,3]
    lhs=P.A(:,1); rhs=P.b-P.A(:,2)*x;
    original=wafer.symbolic.linear_feasible(lhs,rhs,P.strict,1,opts);
    reduced=wafer.symbolic.linear_feasible(zeros(numel(Q.b),0),Q.b-Q.A(:,1)*x,Q.strict,0,opts);
    assert(original==reduced,'Projection feasibility mismatch.');
end
end

