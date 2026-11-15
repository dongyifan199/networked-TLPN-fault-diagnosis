function out = run_wafer12(userOptions)
% Parameterized wafer-processing diagnosis: multiple timed observations.
% Default models: n=[5 10 15 20], m=[1 2].
% Compact report: each model retains fault_early and one seeded
% selection from normal/prefix (two observations for every n,m).
% Run: out=run_wafer12;
%      out=run_wafer12(struct('nList',5,'mList',1));
%      out=run_wafer12(struct('nList',[5 10],'mList',2,...
%                    'scenarios',{{'fault_early','normal','prefix'}}));
%      run_wafer12('selftest');
%      out=run_wafer12(struct('nList',[5 10],'mList',1,...
%                    'scenarios',{{'deep'}},'deepObservedModules',4));
%      run_wafer12('export');
%      run_wafer12('compact_saved'); % format existing complete results
%      out=run_wafer12(struct('selectionMode','full')); % all 24 cases
%
% The TLPN has 5*n+5 transitions, including n+1 hidden faults.
% One networked observation is generated from each feasible simulated
% physical run and its FIFO-delayed arrivals. The diagnosis verdict is
% ALWAYS computed from strict LP feasibility, never assigned by profile.
% Products are built directly as EM-SCG; a full plant MSCG is not built.
% MATLAB Optimization Toolbox (linprog) is required.
% Outputs: wafer_multi_v_results.csv / .mat / .tex; partial files.
% Set reuseGraph=false for independently measured graph construction times.

if nargin>=1 && (ischar(userOptions) || isstring(userOptions))
    command=char(userOptions);
    if strcmp(command,'selftest')
        opts=wafer.config.experiment_options();
        if exist('linprog','file')~=2
            error('MATLAB Optimization Toolbox function linprog is required.');
        end
        opts.lpOptions=optimoptions('linprog','Display','none');
        wafer.tests.fm_projection_selftest(opts);
        wafer.tests.diagnosis_cutoff_selftest();
        wafer.tests.observation_smoke_test(opts);
        fprintf('Projection, timed observations, and cutoff tests: PASS\n');
        out=struct('selftestPassed',true);
        return;
    elseif strcmp(command,'compact_saved')
        % Produce a compact report from already computed experiments.
        data=load('wafer_multi_v_results.mat','T','records');
        if ~isfield(data,'T') || ~isfield(data,'records')
            error('Saved experiment table and records are required.');
        end
        opts=wafer.config.experiment_options();
        [Ts,selectedRows]=wafer.output.select_saved_rows(data.T,data.records,opts);
        view=wafer.output.presentation_table(Ts);
        disp(view);
        writetable(view,'wafer_multi_v_compact.csv');
        wafer.output.write_latex(Ts,'wafer_multi_v_compact.tex');
        save('wafer_multi_v_compact.mat','Ts','view','selectedRows');
        fprintf('Compact report: %d of %d existing cases selected.\n',height(Ts),height(data.T));
        out=struct('table',Ts,'displayTable',view,'selectedRows',selectedRows);
        return;
    elseif strcmp(command,'export')
        data=load('wafer_multi_v_results.mat','T');
        if ~isfield(data,'T'),error('Saved T table not found.');end
        wafer.output.write_latex(data.T,'wafer_multi_v_results.tex');
        fprintf('LaTeX table exported: wafer_multi_v_results.tex\n');
        out=struct('table',data.T);
        return;
    else
        error('Unknown command: %s',command);
    end
end
if nargin<1, userOptions=struct(); end
if ~isstruct(userOptions),error('Options must be a struct.');end
opts=wafer.config.experiment_options();
fn=fieldnames(userOptions);
for i=1:numel(fn),opts.(fn{i})=userOptions.(fn{i});end
if isfield(userOptions,'scenarios') && ~isfield(userOptions,'selectionMode')
    opts.selectionMode='full';
end
if ~any(strcmp(opts.selectionMode,{'compact','full'}))
    error('selectionMode must be compact or full.');
end
if isstring(opts.scenarios),opts.scenarios=cellstr(opts.scenarios);end
if ischar(opts.scenarios),opts.scenarios={opts.scenarios};end
allowed={'fault_early','normal','prefix','deep'};
for j=1:numel(opts.scenarios)
    if ~any(strcmp(opts.scenarios{j},allowed))
        error('Unknown scenario %s',opts.scenarios{j});
    end
end
if exist('linprog','file')~=2
    error('MATLAB Optimization Toolbox function linprog is required.');
end
opts.lpOptions=optimoptions('linprog','Display','none');

fprintf('\nParameterized wafer fault diagnosis (direct EM-SCG)\n');
fprintf('n=[%s]; m=[%s]; scenarios=%s; selection=%s\n',num2str(opts.nList),...
    num2str(opts.mList),strjoin(opts.scenarios,','),opts.selectionMode);
fprintf('Columns: v | n | m | |CH| | |Z| | T_EM | T_D | Result\n\n');
plan=cell(numel(opts.nList),numel(opts.mList));
nCases=0;
for ni=1:numel(opts.nList)
    for mi=1:numel(opts.mList)
        plan{ni,mi}=wafer.config.select_scenarios(opts,opts.nList(ni),opts.mList(mi));
        nCases=nCases+numel(plan{ni,mi});
    end
end
rows=struct('v',{},'n',{},'m',{},'CH',{},'Z',{},'T_EM',{},'T_D',{},'Result',{});
records=cell(nCases,1);
r=0;
for ni=1:numel(opts.nList)
    for mi=1:numel(opts.mList)
        n=opts.nList(ni);m=opts.mList(mi);
        G=wafer.model.wafer_model(n,m);
        S=wafer.network.network_model(n,G);
        cacheSignature='';cacheR=[];cacheTime=NaN;
        selectedProfiles=plan{ni,mi};
        for si=1:numel(selectedProfiles)
            profile=selectedProfiles{si};
            r=r+1;
            obs=wafer.observation.make_observation(G,S,n,m,ni*100+mi,opts,profile);
            str=wafer.observation.format_observation(obs);
            fprintf('(%d/%d) n=%d, m=%d, %s, v=%s\n',r,nCases,n,m,profile,str);
            A=wafer.observation.observation_automaton(obs,S);
            signature=wafer.observation.observation_signature(A);
            if opts.reuseGraph && ~isempty(cacheR) && strcmp(signature,cacheSignature)
                R=cacheR;
                tEM=cacheTime;
                reused=true;
            else
                t0=tic;
                R=wafer.emscg.direct_emscg(G,A,opts);
                tEM=toc(t0);
                cacheR=R;
                cacheSignature=signature;
                cacheTime=tEM;
                reused=false;
            end
            td0=tic;
            [verdict,detail]=wafer.diagnosis.diagnose_paths(G,S,A,R,opts);
            tD=toc(td0);
            rows(r)=struct('v',str,'n',n,'m',m,'CH',n+1,...
                'Z',numel(R.nodes),'T_EM',tEM,'T_D',tD,'Result',verdict);
            if opts.retainGraphs
                records{r}=struct('n',n,'m',m,'profile',profile,...
                    'model',G,'network',S,'observation',obs,...
                    'automaton',A,'EMSCG',R,'diagnosis',detail,...
                    'EMreused',reused);
            else
                records{r}=struct('n',n,'m',m,'profile',profile,...
                    'observation',obs,'nodes',numel(R.nodes),...
                    'contexts',numel(R.contexts),'edges',numel(R.edges),...
                    'diagnosis',detail,'EMreused',reused);
            end
            fprintf('         |Z|=%d; contexts=%d; edges=%d; T_EM=%ss; T_D=%ss; %s',...
                numel(R.nodes),numel(R.contexts),numel(R.edges),...
                wafer.output.format_seconds(tEM),wafer.output.format_seconds(tD),verdict);
            if reused, fprintf(' (same logical EM-SCG reused)');end
            fprintf('\n');
            if opts.saveResults
                part=struct2table(rows);
                writetable(wafer.output.presentation_table(part),'wafer_multi_v_partial.csv');
                save('wafer_multi_v_partial.mat','rows','records','opts','-v7.3');
            end
            if opts.saveEveryCase
                save(sprintf('wafer_n%d_m%d_%s.mat',n,m,profile),...
                    'G','S','A','R','obs','detail','-v7.3');
            end
        end
        clear cacheR R;
    end
end
T=struct2table(rows);
view=wafer.output.presentation_table(T);
disp(view);
if opts.saveResults
    writetable(view,'wafer_multi_v_results.csv');
    save('wafer_multi_v_results.mat','T','view','rows','records','opts','-v7.3');
    wafer.output.write_latex(T,'wafer_multi_v_results.tex');
end
out=struct('table',T,'displayTable',view,'rows',{rows},'cases',{records},'options',opts);
end

