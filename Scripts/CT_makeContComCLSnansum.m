function contcom = CT_makeContComCLS(ps,deg1,deg2)
%adapted for asyncrhony, deg1 input can be an adjacency radius,
%if deg2 is present, deg1 is before, and deg2 is after

if nargin==2
    deg2=deg1;
end
degrees=deg1+deg2;

% for i=numel(ps):-1:2
%     if ps(i)==ps(i-1)
%         ps(i)=[];
%     end
% end

contcom=nan(degrees,numel(ps));
for n=1:numel(ps)
    for i=1:deg1
        try
            if ps(n) > ps(n-i)
                contcom(deg1+1-i,n)=1;
            else
                contcom(deg1+1-i,n)=0;
            end
        catch %value will be nan
%             n
%             i 
%             deg2
%             if ps(n) > ps(n+deg2+abs(n-i)+1)
%                 contcom(deg1+1-i,n)=1;
%             else
%                 contcom(deg1+1-i,n)=0;
%             end
        end
        
    end
    for i=1:deg2
        try
            if ps(n) > ps(n+i)
                contcom(deg1+i,n)=1;
            else
                contcom(deg1+i,n)=0;
            end
        catch %value will be nan
%             if ps(n) > ps(n-(deg1+abs(numel(ps)-(n+i))))
%                 contcom(deg1+i,n)=1;
%             else
%                 contcom(deg1+i,n)=0;
%             end
        end
    end
end
contcom=nansum(contcom);
end

