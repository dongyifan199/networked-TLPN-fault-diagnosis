function txt=format_seconds(seconds)
% Computation time in seconds: one decimal at 0.05 s and above.
if ~isscalar(seconds) || ~isnumeric(seconds) || ~isfinite(seconds) || seconds<0
    error('Invalid computation time.');
end
if seconds < 0.05
    txt=sprintf('%.3f',seconds);
else
    txt=sprintf('%.1f',seconds);
end
end
