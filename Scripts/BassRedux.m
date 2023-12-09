function nmat=BassRedux(nmat)
% clear
% filename='Benda.mid'; % file to be analyzed
% nmat=midi2nmat(filename); % conversion of file to nmat format (n x 7 matrix)

nmat(:,8)=1:numel(nmat(:,1)); % add an eighth column that's an index to the original
rawmat=nmat; %store the raw nmat
durlimit=2;
quant=in.quant;

%% create vmat
% (separate nmat into multiple nmats, one for each voice)
nv=max(nmat(:,3));
vmat{nv}=[];
pitchmean(nv)=0;
for i=1:nv % for loop where i is the voices 1 to n
    ind=nmat(:,3)==i;%+1-nmatmin; % index of nmat rows for voice i/channel i-1 (channels start with 0)
    vmat{i}=nmat(ind,:); % extract nmat rows for voice i/channel i-1
    vmat{i}(:,1)=round(vmat{i}(:,1),4); % round onset to 4th decimal place
    vmat{i}(:,1)=(floor(vmat{i}(:,1)/quant))*quant; % floor round onset to minimum quantization
    pitchmean(i)=mean(vmat{i}(:,4)); % mean pitch for voice i/channel i-1
end
[~, ind]=sort(pitchmean,'descend'); % sort by mean pitch for each voice
vmat=vmat(ind); % order voice mats by pitch height (highest will be vmat {1})


%for x=1:numel(vmat)
    bmat=vmat{nv};
    %% take out rests on beats
    for i=numel(bmat(:,1)):-1:1
        test=floor(bmat(i,1));
        if i>1
            if test~=floor(bmat(i-1,1))
                ind=find(bmat(:,1)==test);
                if numel(ind)==0
                    bmat(i,1)=test;
                end
            end
        else
            ind=find(bmat(:,1)==test);
            if numel(ind)==0
                bmat(i,1)=test;
            end
        end
    end
    
    
    %% take out repeated notes mod 12
    for i=numel(bmat(:,1))-1:-1:1
        if rem(bmat(i+1,1),1)~=0
            if mod(bmat(i,4),12)==mod(bmat(i+1,4),12)
                bmat(i,2)=bmat(i+1,1)-bmat(i,1)+bmat(i,2);
                bmat(i+1,:)=[];
            end
        end
    end
    
    %% find arpeggios
    triad=[0,3,7];
    ints=[0,3,4,5];
    cand=ones(1,8);
    purg=ones(1,8);
    for i=numel(bmat(:,1))-3:-1:1
        test=rem(bmat(i,1),1);
        if test~=0
            test2=floor(bmat(i,1));
            temp=find(bmat(:,1)==test2);
            if numel(temp)>0
                continue
            end
        end
        p=bmat(i:i+3,4);
        p=p';
        [pf,nf,t,t_loc]=primeform(p);
        if numel(pf)==3
            if pf==triad
                while numel(p)<=10
                    try
                        p(end+1)=bmat(i+numel(p),4);
                        dur=bmat(i+numel(p)-1,1)-bmat(i,1)+bmat(i+numel(p)-1,2);
                        [pf,nf,t,t_loc]=primeform(p);
                        if numel(pf)==3
                            if pf~=triad
                                
                                p(end)=[];
                                break
                            elseif dur > durlimit
                                
                                p(end)=[];
                                break
                            else
                                continue
                            end
                        else
                            p(end)=[];
                            break
                        end
                    catch
                        
                        break
                    end
                end
                [pf,nf,t,t_loc]=primeform(p);
                cand(end+1,:)=bmat(i,:);
                root=p(t_loc(1));
                dur=bmat(i+numel(p)-1,1)-bmat(i,1)+bmat(i+numel(p)-1,2);
                cand(end,4)=root;
                cand(end,2)=dur;
                purg(end+1:end+numel(p),:)=bmat(i:i+numel(p)-1,:);
            end
        elseif numel(pf)==4
            [pf,nf,t,t_loc]=primeform(p(1:3));
            if numel(pf)==3
                if pf==triad
                    cand(end+1,:)=bmat(i,:);
                    root=p(t_loc(1));
                    dur=bmat(i+2,1)-bmat(i,1)+bmat(i+2,2);
                    cand(end,4)=root;
                    cand(end,2)=dur;
                    purg(end+1:end+3,:)=bmat(i:i+2,:);
                end
            end
        end
    end
    
    cand(1,:)=[];
    ind=find(cand(:,2)>durlimit+.1);
    cand(ind,:)=[];
    for i=numel(cand(:,1)):-1:1
        onset=cand(i,1);
        offset=onset+cand(i,2);
        ind=find(bmat(:,1)>=onset & bmat(:,1)<offset);
        candpitch=cand(i,4);
        nextpitch=bmat(ind(end)+1,4);
        if abs(candpitch-nextpitch)>=3
            lastpitch=bmat(ind(end),4);
            if abs(lastpitch-nextpitch)<=3
                bmat(ind(1:end-1),:)=[];
            else
                bmat(ind,:)=[];
            end
        else
            bmat(ind,:)=[];
        end
    end
    bmat=[bmat;cand];
    [~,ind]=sort(bmat(:,1));
    bmat=bmat(ind,:);
    bmat(:,6:7)=bmat(:,1:2)/2;
    vmat{nv}=bmat;
    
newnmat=[1,1,1,1,1,1,1,1];

for i=1:nv
    newnmat=[newnmat;vmat{i}];
end
newnmat(1,:)=[];
nmat=newnmat;
end