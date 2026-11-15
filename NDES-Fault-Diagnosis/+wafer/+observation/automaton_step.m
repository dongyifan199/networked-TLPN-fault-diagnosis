function [qnext,ok,matched]=automaton_step(A,q,ch,label)
qnext=q;ok=true;matched=false;
if ch==0,return;end
if q(ch)<A.counts(ch)
    if ~strcmp(label,A.required{ch}{q(ch)+1})
        ok=false;return;
    end
    qnext(ch)=q(ch)+1;
    matched=true;
end
end

