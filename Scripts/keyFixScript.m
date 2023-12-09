%nmat=midi2nmat('Mozart_piano_sonata_545_mvmt1.mid');
nmat=midi2nmat('Fugue-BWV-847.mid');
rawmat=nmat;
        [~,nmat]=nmatSortByChans(nmat);

    %handles.nmat=nmat;
    nmat=restasnan(nmat);

[r,~,~,nmat]=searchAndRankSimplePoly2(nmat,1,5);
rraw=r
rselect=1;
%40.5.48.25
%r=addKey(r(rselect),rawmat);
r=r(rselect)
r(1).segind=78
r(1).card=16

for j=1:numel(r)
    %nmat=r(j).nmatSR;
    segind=r(j).segind;
    clear key tonic
    n=numel(segind);
    key(n)=0;
    %tonic(n)=0;
    for i=1:n
        card=r(j).card(i);
        start=nmat(segind(i),1);        
        stop=nmat(segind(i)+card-1,1);%+nmat(segind(i)+card-1,2);
        ind=find(rawmat(:,1)>=start & rawmat(:,1)<=stop);
        keyRefMat{i}=rawmat(ind,:);
%         voice=nmat(segind(i),3);
%         ind=find(keyRefMat{i}(:,3)==voice);
%         keyRefMat{i}=keyRefMat{i}(ind,:);
        try
        [~, k(1)] = max(kkcc(keyRefMat{i}));
        catch
            k(1)=nan;
        end
        try
        [~, k(2)] = max(kkcc(keyRefMat{i},'TEMPERLEY'));
        catch
            k(2)=nan;
        end
        try
        [~, k(3)] = max(kkcc(keyRefMat{i},'ALBRECHT-SHANAHAN'));
        catch
            k(3)=nan;
        end

        ind=find(isnan(k));
        k(ind)=[];
        kmode=mode(k);
        ind=find(k==mode(k));
        if numel(unique(k))==1 && numel(k)>1
            key(i)=mode(k);
            tonic(i)=mod(key(i)-1,12);
        elseif numel(ind)>1
            key(i)=mode(k)
            tonic(i)=mod(key(i)-1,12);
        else
            key(i)=nan;
            tonic(i)=nan;
        end
    end
    r(j).key=key;
end