function write_latex(T,path)
fid=fopen(path,'w');
if fid<0,error('Unable to create LaTeX table.');end
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'\\begin{table*}[t]\n\\centering\n');
fprintf(fid,'\\caption{Computational results for the wafer-processing benchmark}\n');
fprintf(fid,'\\resizebox{\\textwidth}{!}{%%\n');
fprintf(fid,'\\begin{tabular}{c c c c c c c c}\\hline\n');
fprintf(fid,'$v$ & $n$ & $m$ & $|CH|$ & $|\\mathcal Z|$ & $T_{\\rm EM}$ (s) & $T_D$ (s) & Result \\\\ \\hline\n');
for k=1:height(T)
    v=wafer.output.table_text_at(T,'v',k);
    result=wafer.output.table_text_at(T,'Result',k);
    % Record the complete timed observation.
    fprintf(fid,'\\texttt{%s} & %d & %d & %d & %d & %s & %s & %s \\\\ \n',...
        wafer.output.tex_escape(v),T.n(k),T.m(k),T.CH(k),T.Z(k),wafer.output.format_seconds(T.T_EM(k)),...
        wafer.output.format_seconds(T.T_D(k)),result);
end
fprintf(fid,'\\hline\\end{tabular}}\n\\end{table*}\n');
end

