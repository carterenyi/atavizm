function d = lev(s,t)
% Levenshtein distance between strings or char arrays.
% lev(s,t) is the number of deletions, insertions,
% or substitutions required to transform s to t.
% https://en.wikipedia.org/wiki/Levenshtein_distance

    s = char(s);
    t = char(t);
    m = length(s);
    n = length(t);
    x = 0:n;
    y = zeros(1,n+1);   
    for i = 1:m
        y(1) = i;
        for j = 1:n
            c = (s(i) ~= t(j)); % c = 0 if chars match, 1 if not.
            y(j+1) = min([y(j) + 1
                          x(j+1) + 1
                          x(j) + c]);
        end
        % swap
        [x,y] = deal(y,x);
    end
    d = x(n+1);
end