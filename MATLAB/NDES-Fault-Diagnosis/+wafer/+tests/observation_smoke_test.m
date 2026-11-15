function observation_smoke_test(opts)
% Validate source trajectories and the delayed observations they produce.
for m=[1,2]
    G=wafer.model.wafer_model(5,m);
    S=wafer.network.network_model(5,G);
    assert(size(G.Pre,2)==5*G.n+5);
    assert(nnz(G.fault)==G.n+1);
    profiles={'fault_early','normal','prefix','deep'};
    for p=1:numel(profiles)
        o=wafer.observation.make_observation(G,S,5,m,101,opts,profiles{p});
        assert(~isempty(o.labels) && numel(o.labels)==numel(o.arrivals));
        assert(all(diff(o.arrivals)>=-1e-10));
        if strcmp(profiles{p},'prefix')
            assert(nnz(strcmp(o.labels,'a'))>=m,...
                'Short-prefix observation is missing a received loadlock label.');
        elseif strcmp(profiles{p},'fault_early') && m==1
            assert(any(strcmp(o.labels,'b2')),...
                'Early-fault observation must include a received module-2 label.');
        end
        assert(isequal(size(o.trueTransitions),size(o.trueDeltas)));
        for j=1:numel(o.arrivals)
            d=o.arrivals(j)-o.times(j);
            ch=o.channels(j);
            assert(d>=S.delay(ch,1)-1e-8 && ...
                d<S.delay(ch,2),'Invalid generated channel delay.');
        end
        if strcmp(profiles{p},'normal')
            assert(~o.trueFault,'Nominal observation contains a fault.');
        elseif strcmp(profiles{p},'fault_early')
            assert(o.trueFault,'Fault observation does not contain a fault.');
        end
        wafer.tests.validate_timed_trace(G,o.trueTransitions,o.trueDeltas);
    end
end
end

