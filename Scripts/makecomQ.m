function comQ = makecomQ(ps)

%if nargin==1
    phrBeg=1;
    phrEnd=numel(ps);
%end

for n=1:numel(phrBeg)
    phrpitches=ps(phrBeg(n):phrEnd(n));
    %phrML=cell(numel(phrpitches));
    phrQ=nan(numel(phrpitches));
    for i=1:numel(phrpitches)
        for j=1:numel(phrpitches)
            if phrpitches(j) > phrpitches(i)
                %phrML{i,j}='+';
                phrQ(i,j)=1;
            elseif phrpitches(j)==phrpitches(i)
                %phrML{i,j}='0';
                phrQ(i,j)=0;
            elseif phrpitches(j) < phrpitches(i)
                %phrML{i,j}='-';
                phrQ(i,j)=0;
            end
        end
    end
    ps=phrpitches;
    %phr(n).comML=phrML;

end
    comQ=phrQ;
end
