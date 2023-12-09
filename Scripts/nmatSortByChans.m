function [nmat,nmatFound]=nmatSortByChans(nmat,chanSel)
%nmatold=nmat;
chans=unique(nmat(:,3));
numchans=numel(chans);

for z=1:numchans
    ind= nmat(:,3)==chans(z);
    chanmat{z}=nmat(ind,:);
    chanmat{z}(:,3)=z;
%     if z<numchans
%         chanmat{z}(end+1,:)=chanmat{z}(end,:);
%         chanmat{z}(end,1)=chanmat{z}(end-1,1)+chanmat{z}(end-1,2);
%         chanmat{z}(end,2)=.5;
%         chanmat{z}(end,4)=nan;
%     end
    %     if z > 1
    %         chanmat{z}(:,1)=chanmat{z}(:,1)+round(allchans(end,1));
    %         chanmat{z}(:,6)=chanmat{z}(:,6)+round(allchans(end,6));
    %     end
end

for z=1:numchans
        ind= nmat(:,3)==chans(z);
        nmat(ind,3)=z;
end
allchans=[];
if nargin==2
    for i=1:numel(chanSel)
        allchans=vertcat(allchans,chanmat{chanSel(i)});
    end
else
    for i=1:numchans
        allchans=vertcat(allchans,chanmat{i});
    end
end
nmat=nmat;
nmatFound=allchans;
end

