function r=addKey(r,rawmat,type)

if numel(type)>1
    types={'Krumhansl-Kessler','Temperley','Albrecht-Shanahan','Agree All','Agree 2/3'};
    for i=1:5
        if strcmp(type,types{i})==1
        type=i;
        break
        end
    end
end
%type=type
for j=1:numel(r)
    nmat=r(j).nmatSR;
    segind=r(j).segind;
    clear key tonic keytext
    n=numel(segind);
    key(n)=0;
    keytext{n}=[];
    %tonic(n)=0;
    for i=1:n
        card=r(j).card(i);
        if type<4
            start=nmat(segind(i),1);
            %stop=nmat(segind(i)+card-1,1)+nmat(segind(i)+card-1,2);
            stop=nmat(segind(i)+card-1,1);%+nmat(segind(i)+card-1,2);
            ind=find(rawmat(:,1)>=start & rawmat(:,1)<=stop);
            keyRefMat{i}=rawmat(ind,:);
            %         voice=nmat(segind(i),3);
            %         ind=find(keyRefMat{i}(:,3)==voice);
            %         keyRefMat{i}=keyRefMat{i}(ind,:);
            if type==1
                [~, k] = max(kkcc(keyRefMat{i}));
            elseif type==2
                [~, k] = max(kkcc(keyRefMat{i},'TEMPERLEY'));
            elseif type==3
                [~, k] = max(kkcc(keyRefMat{i},'ALBRECHT-SHANAHAN'));
            end
            
            
            key(i)=k;
            tonic(i)=mod(key(i)-1,12);
        elseif type==4
            start=nmat(segind(i),1);
            stop=nmat(segind(i)+card-1,1)+nmat(segind(i)+card-1,2);
            %stop=nmat(segind(i)+card-1,1);%+nmat(segind(i)+card-1,2);
            ind=find(rawmat(:,1)>=start & rawmat(:,1)<stop);
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
            else
                key(i)=nan;
                tonic(i)=nan;
            end
        elseif type==5
            start=nmat(segind(i),1);
            stop=nmat(segind(i)+card-1,1)+nmat(segind(i)+card-1,2);
            %stop=nmat(segind(i)+card-1,1);%+nmat(segind(i)+card-1,2);
            ind=find(rawmat(:,1)>=start & rawmat(:,1)<stop);
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
            %kmode=mode(k);
            ind=find(k==mode(k));
            if numel(unique(k))==1 && numel(k)>1
                key(i)=mode(k);
                tonic(i)=mod(key(i)-1,12);
            elseif numel(ind)>1
                key(i)=mode(k);
                tonic(i)=mod(key(i)-1,12);
            else
                key(i)=nan;
                tonic(i)=nan;
            end
        end
        if isnan(key(i))==0
            keytext{i}=keyname(key(i),2);
            keytext{i}=keytext{i}{1};
        else
            keytext{i}='';
        end
    end
    r(j).key=key;
    r(j).keytext=keytext;
    r(j).keyaxi=key;
    r(j).keyDisp=1;
end