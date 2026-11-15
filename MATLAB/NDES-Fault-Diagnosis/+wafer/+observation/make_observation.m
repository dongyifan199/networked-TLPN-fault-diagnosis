function observation=make_observation(G,S,n,m,caseNo,opts,profile)
% A deterministic, physically feasible timed trajectory is simulated.
% Three different trajectory/communication-delay settings give candidate
% observations. The actual F/N/U result is decided ONLY by diagnosis LP.
% fault_early: prioritize hidden faults and short communication delays.
% normal: prioritize fault-free processing and moderate delays.
% prefix: stop at first module-1 output, exposing a short received prefix.
% deep: normal processing, continuing until b_min(n,deepObservedModules).
wantFault=strcmp(profile,'fault_early');
M=G.M0;Nt=numel(G.tname);
ages=nan(Nt,1);E=wafer.model.enabled(G,M);ages(E)=0;
clock=0;
physical=struct('t',{},'label',{},'channel',{},'time',{});
trace=zeros(1,0);deltas=zeros(1,0);
for step=1:opts.maxSimulationSteps
    E=wafer.model.enabled(G,M);
    if isempty(E),break;end
    upper=min(G.I(E,2)-ages(E));
    lower=max(0,G.I(E,1)-ages(E));
    candidates=E(lower<upper-opts.numericTolerance);
    if isempty(candidates)
        error('No fireable transition while generating %s observation (n=%d,m=%d).',...
            profile,n,m);
    end
    score=zeros(size(candidates));
    for ii=1:numel(candidates)
        t=candidates(ii);
        dt=max(0,G.I(t,1)-ages(t));
        score(ii)=dt;
        if G.fault(t)
            % Inject at most one fault in the first processing module.
            % All other fault alternatives remain present in the TLPN
            % and are explored during diagnosis.
            singleTarget=strcmp(G.tname{t},'t15') && ...
                ~any(G.fault(trace));
            if wantFault && singleTarget
                score(ii)=score(ii)-5;
            else
                score(ii)=score(ii)+10;
            end
        end
        if G.ch(t)>0,score(ii)=score(ii)-0.02;end
        % Prefer starting a wafer transfer only when its source buffer is
        % available. This selects a production trajectory; it does not
        % modify the TLPN enabling relation or the diagnosis search.
        if t==1 && M(G.raw)==0
            score(ii)=score(ii)+100;
        elseif t>=5 && t<=4*n+1 && mod(t-5,4)==0
            im=(t-5)/4+1;
            if M(G.mod(im,4))==0
                score(ii)=score(ii)+100;
            end
        end
    end
    [~,ix]=min(score);
    t=candidates(ix);
    dtMin=max(0,G.I(t,1)-ages(t));
    if isinf(upper)
        dt=dtMin+0.05;
    else
        % Every delay remains below the earliest current deadline.
        if strcmp(profile,'fault_early')
            fraction=0.005;
        elseif strcmp(profile,'normal')
            fraction=0.15;
        else
            fraction=0.04;
        end
        dt=dtMin+fraction*(upper-dtMin);
    end
    if dt<0 || ~(dt<upper)
        error('Invalid generated firing delay (n=%d,m=%d).',n,m);
    end
    clock=clock+dt;
    oldE=E;ages(oldE)=ages(oldE)+dt;
    Mmid=M-G.Pre(:,t);
    M=M+G.Post(:,t)-G.Pre(:,t);
    newE=wafer.model.enabled(G,M);
    newAge=nan(Nt,1);
    for j=newE(:)'
        if j==t || ~any(oldE==j) || ~all(Mmid>=G.Pre(:,j))
            newAge(j)=0;
        else
            newAge(j)=ages(j);
        end
    end
    ages=newAge;
    trace(end+1)=t; %#ok<AGROW>
    deltas(end+1)=dt; %#ok<AGROW>
    if G.ch(t)>0
        physical(end+1)=struct('t',t,'label',G.label{t},...
            'channel',G.ch(t),'time',clock); %#ok<AGROW>
        % The cutoff is the time of a generated observable event.
        % Select an event late enough for the required channel data to arrive.
        labels={physical.label};
        if strcmp(profile,'prefix')
            ready=strcmp(G.label{t},'b1') && nnz(strcmp(labels,'b1'))>=m;
        elseif strcmp(profile,'fault_early') && m==1 && n>=3
            % Receive b2 before the cutoff so premature module processing
            % can be distinguished from a fault-free execution.
            ready=strcmp(G.label{t},'b3');
        elseif strcmp(profile,'deep')
            ready=strcmp(G.label{t},sprintf('b%d',min(n,opts.deepObservedModules)));
        else
            ready=strcmp(G.label{t},'b2');
        end
        if ready
            candidate=wafer.observation.project_arrivals(physical,S,n,m,profile,caseNo);
            if isempty(candidate.labels)
                % Continue the physical execution until data have arrived.
                continue;
            end
            if strcmp(profile,'prefix')
                acceptable=nnz(strcmp(candidate.labels,'a'))>=m;
            elseif strcmp(profile,'fault_early') && m==1 && n>=3
                acceptable=any(strcmp(candidate.labels,'b2'));
            else
                acceptable=any(strcmp(candidate.labels,'b1'));
            end
            if acceptable
                observation=candidate;
                observation.trueTransitions=trace;
                observation.trueDeltas=deltas;
                observation.trueTimeCutoff=clock;
                observation.trueFault=any(G.fault(trace));
                observation.profile=profile;
                return;
            end
        end
    end
end
error('Could not generate the requested %s observation (n=%d,m=%d).',...
    profile,n,m);
end

