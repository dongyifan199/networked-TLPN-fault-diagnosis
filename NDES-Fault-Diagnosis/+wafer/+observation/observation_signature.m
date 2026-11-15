function sig=observation_signature(A)
% EM-SCG graph depends on the per-channel required label prefixes,
% not on the numerical arrival timestamps used by the diagnosis LP.
parts=cell(1,A.nCH);
for ch=1:A.nCH
    parts{ch}=sprintf('%d:%s',ch,strjoin(A.required{ch},','));
end
sig=strjoin(parts,'|');
end

