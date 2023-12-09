function r=schemaID2(r,in)
%r=rsave(rselect);
%numel(nmat(:,1))
%r(1).segind=r(1).segind
%r=r;
nmat=r(1).nmatSR;
onsets=nmat(r(1).segind,1);
[~,IA,~]=unique(onsets);
r(1).segind=r(1).segind(IA);
r(1).key=r(1).key(IA);
sto=in.sto;
revise=in.revise;
TRSkey=in.TRSkey;

if isempty(sto)==0
%ELIMINATE REDUNDALT RESULTS PRODUCED BY SKIPGRAM
for i=1:numel(sto)
    onsets=nmat(r(1).segind,1);
    for j=numel(r(1).segind):-1:2
        if onsets(j)-sto(i)==onsets(j-1)
            %onsets(j)
            p1=nmat(r(1).segind(j):r(1).segind(j)+r(1).card(1)-1,4)';
            p2=nmat(r(1).segind(j-1):r(1).segind(j-1)+r(1).card(1)-1,4)';
            if mod(p1,12)==mod(p2,12)
                r(1).segind(j)=[];
                r(1).card(j)=[];
                r(1).key(j)=[];
            end
        end
    end
end
end
%segind=r(1).segind;

%% identify scale degrees of schema
schsz=r.card(1);
segind=r.segind;
card=r.card(1);

schema{numel(segind)}=[];
for i=1:numel(segind)
    ind=segind(i);
    stoInst=nmat(ind,2);
    onsets=nmat(ind:ind+schsz-1,1);
    ind=[];
    for j=1:numel(onsets)
        ind=[ind;find(in.rawmat(:,1)==onsets(j))];
    end
    schema{i}=in.rawmat(ind,:);
    schema{i}=unique(schema{i},'rows');
    if isempty(sto)==0
    for j=numel(schema{i}(:,1)):-1:1
        if schema{i}(j,2)~=stoInst
            schema{i}(j,:)=[];
        end
    end
    end
%     v=unique(schema{i}(:,3));
    
%     for k=1:numel(v)
%         ind=find(schema{i}(:,3)==v(k));
%         voice{i}{k}=schema{i}(ind,:);
%     end
    
    for j=1:numel(onsets)
        ind=schema{i}(:,1)==onsets(j);
        slice{i}{j}=schema{i}(ind,:);
        %nv=numel(ind);
    end
        v=nmat(segind(i),3);
    ind=schema{i}(:,3)==v;
    schemaPitch{i}=schema{i}(ind,4);
end

%if TRSkey==0
n=numel(segind);
key=r(1).key;
% tonic(n)=0;
tonic=mod(key-1,12);
schemaPitch{n}=[];

if TRSkey==1
tt{n}=[];
ttv{n}=[];
for i=1:n

    if isnan(tonic(i))==1
        for j=1:numel(onsets)
            %continueit=0;
            p=slice{i}{j}(:,4);
            nv=numel(p);
            if nv==1
                continue
            end
            for k=1:nv
                
                for l=k:nv
                    if mod(abs(p(k)-p(l)),12)==6
                        tt{i}(j)=1;
                        ttv{i}(1:3,j)=[p(k),p(l),slice{i}{j}(1,1)];
                        break
                    elseif mod(abs(p(k)-p(l)),12)==10
                        tt{i}(j)=2;
                        ttv{i}(1:3,j)=[p(k),p(l),slice{i}{j}(1,1)];
                        break
                    else
                        tt{i}(j)=0;
                        ttv{i}(1:3,j)=[0,0,0];
                    end
                end
                if tt{i}(j)==1
                    break
                end
                
            end
            if j==numel(onsets)
                continue
            end
            %if exist('tt')==1
            if tt{i}(j)==1
                o=ttv{i}(3,j);
                p=ttv{i}(1:2,j);
                for k=1:2
                    ind=find(schema{i}(:,1)>o);
                    ind2=find(schema{i}(ind,4)==p(k)+1);
                    if numel(ind2)>0
                        t=schema{i}(ind(ind2(1)),4);
                        tonic(i)=mod(t,12);
                        break
                    end
                end
                
                
            elseif tt{i}(j)==2
                o=ttv{i}(3,j);
                p=ttv{i}(1:2,j);
                for k=1:2
                    ind=find(schema{i}(:,1)>o);
                    ind2=find(schema{i}(ind,4)==p(k)+5);
                    if numel(ind2)>0
                        t=schema{i}(ind(ind2(1)),4);
                        tonic(i)=mod(t,12);
                        break
                    end
                end
            end
        end
    end
end
end

% copy tonic of exact pitch mod 12
for i=1:n
    if isnan(tonic(i))==0
        for j=1:n
            if i==j
                continue
            elseif isnan(tonic(j))==0
                continue
            end
            p1=nmat(segind(i):segind(i)+card-1,4)';
            p2=nmat(segind(j):segind(j)+card-1,4)';
            if mod(p1,12)==mod(p2,12)
                tonic(j)=tonic(i);
            end
        end
        
    end
end


for i=1:n
    if tonic(i)<12
        schema{i}(:,10)=tonic(i);
        schema{i}(:,11)=mod(schema{i}(:,4)-tonic(i),12);
    end
end


% find average schema
pschema{n}=[];
for i=1:n
    v=nmat(segind(i),3);
    ind=find(schema{i}(:,3)==v);
    schemaPitch{i}=schema{i}(ind,4);
    if tonic(i)<12
        pschema{i}=schema{i}(ind,11);
        if numel(pschema{i})>card
            for j=numel(pschema{i}):-1:1
                if isnan(pschema{i}(j))==1
                    pschema{i}(j)=[];
                end
            end
        end
        pschema{i}=spec2gen(pschema{i});
    else
        pschema{i}=[];
    end
end

[ups,~,IC]=uniquecell(pschema);
sch=ups{mode(IC)};
if isempty(sch)==1
    try
    ind=IC==mode(IC);
    temp=pschema;
    temp(ind)=[];
    [ups,~,IC]=uniquecell(temp);
    sch=ups{mode(IC)};
    catch
    end
end
ind=find(IC==mode(IC));
species{numel(ind)}=[];
for i=1:numel(ind)
    schemaPitch{ind(i)}(1:card-1)
    schemaPitch{ind(i)}(2:card)
    species{i}=schemaPitch{ind(i)}(2:card)-schemaPitch{ind(i)}(1:card-1);
end
species=uniquecell(species);
for j=1:numel(species)
    for i=1:numel(pschema)
        test=schemaPitch{i}(2:card)-schemaPitch{i}(1:card-1);
        if test==species{j}
            pschema{i}=sch;
            if ismember(1,sch)==1
                ind=find(sch==1);
                tonic(i)=mod(schemaPitch{i}(ind(1)),12);
            elseif ismember(5,sch)==1
                ind=find(sch==5);
                schP=schemaPitch{i}(ind(1));
                tonic(i)=mod(schP+5,12);
            end
        end
    end
end


%% revise r
r(1).seg=sch;
r(1).name=['SDS [' num2str(sch) ']'];
r(1).type=5;
r(1).nmatSR=nmat;
if revise==0
    %keyout=tonic+1;
    for i=1:n
        r(1).key(i)=tonic(i)+1;
            r(1).keyaxi=nan;
    end
elseif revise==1
    segindold=r(1).segind;
    r(1).segind=[];
    r(1).key=[];
    r(1).keyaxi=[];
    for i=1:n
        if numel(pschema{i})==numel(sch)
            if pschema{i}==sch
                r(1).segind(end+1)=segindold(i);
                r(1).key(end+1)=tonic(i)+1;
                r(1).keyaxi(end+1)=nan;
            end
        end
        
    end
    r(1).segcount=numel(r(1).segind);
    r(1).cov=r(1).segcount*schsz;
    r(1).card=ones(1,numel(r(1).segind))*card;
end

    r(1).keyDisp=0;
    r(1).axi=[];
        r(1).arcType=1;
        r(1).show=1;
        r(1).arcDir=1;
end
