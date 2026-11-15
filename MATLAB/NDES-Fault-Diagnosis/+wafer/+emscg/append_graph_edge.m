function R=append_graph_edge(R,src,dst,t,G,c,renaming,opts)
if opts.edgeAnnotations
    [loStr,hiStr]=wafer.emscg.edge_bounds(G,c,t);
else
    loStr='';hiStr='';renaming={};
end
e=numel(R.edges)+1;
R.edges(e)=struct('src',src,'dst',dst,'t',t,...
    'name',G.tname{t},'label',G.label{t},...
    'Delta',sprintf('D%d',src),'lower',loStr,...
    'upper',hiStr,'renaming',{renaming});
end

