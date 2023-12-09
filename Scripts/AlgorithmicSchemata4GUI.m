function nmat=AlgorithmicSchemata4GUI(nmat,in)
% if nargin==2
    %General
    sel=in.sel;
    bass=in.bass;
    %meter=in.meter; %meter for piece in quarter notes
    type=in.type;
    regOnsets=in.regOnsets;
    slice2bass=in.slice2bass;
    TRS=in.TRS;
    consInts=in.consInts;
    redRepNonBass=in.redRepNonBass;
    redRepBass=in.redRepBass;
    rrRem=in.rrRem;
    quant=in.quant;
    %pointsOnOff=in.pointsOnOff;
    if type>1
        varParam=in.varParam;
    end
    %Pitch (Contour Level Points=CLP)
    CLP(1)=in.CL4; % points awarded for durational maxima within window of four
    CLP(2)=in.CL3; % points awarded for durational submaxima within window of four
    CLP(3)=in.CL2; % points awarded for durational medium within window of four
    CLP(4)=in.CL1; % points awarded for durational superminima within window of four
    CLP(5)=in.CL0; % points awarded for durational minima within window of four
    %Duration (Duration Level Points=DLP)
    DLP(1)=in.DL4; % points awarded for durational maxima within window of four
    DLP(2)=in.DL3; % points awarded for durational submaxima within window of four
    DLP(3)=in.DL2; % points awarded for durational medium within window of four
    DLP(4)=in.DL1; % points awarded for durational superminima within window of four
    DLP(5)=in.DL0; % points awarded for durational minima within window of four
    DPthresh=in.DPthresh;
    DP=in.DP;
    %Onsets
    remP(4)=in.rem4; % points awarded for onset remainder after dividing by 4
    remP(3)=in.rem3; % points awarded for onset remainder after dividing by 3
    remP(2)=in.rem2; % points awarded for onset remainder after dividing by 2
    remP(1)=in.rem1; % points awarded for onset remainder after dividing by 1
    upbeat=in.upbeat; % points awarded for onset remainder after dividing by 3 with an offset of 1
    %contiguity
    contbonus=in.contBonus;
    bonusint=2; % notes at or within this interval  (excluding zero) will be awarded the points in contbonus
    contWindow=in.contWindow;
    contthresh=in.contThresh; % pitch contiguity threshold (notes around these are "infected")
    adjCont=in.adjCont;
    adjContBonus=in.adjContBonus;
    
    
    
% else
%     DL4=1; % points awarded for durational maxima within window of four
%     DL3=1; % points awarded for durational submaxima within window of four
%     DL2=0; % points awarded for durational medium within window of four
%     DL1=0; % points awarded for durational superminima within window of four
%     DL0=0; % points awarded for durational minima within window of four
%     rem4=0; % points awarded for onset remainder after dividing by 4
%     rem3=0; % points awarded for onset remainder after dividing by 3
%     rem3_1=0; % points awarded for onset remainder after dividing by 3 with an offset of 1
%     rem2=0; % points awarded for onset remainder after dividing by 2
%     rem1=1; % points awarded for onset remainder after dividing by 1
%     contthresh=2; % pitch continuity threshold (notes around these are "infected")
%     bonusint=2; % notes at or within this interval  (excluding zero) will be awarded the points in contbonus
%     contbonus=1; % bonus points for continuity
%     meter=2; %meter for piece in quarter notes
%     % penaltyint=8; % (unused) notes at or beyond this interval will be given a penalty
%     % contpenalty=-1; % (unused) points taken away for discontinuity
%     %filename='bendatest.mid'; % file to be analyzed
%     %nmat=midi2nmat(filename); % conversion of file to nmat format (n x 7 matrix)
%     type=1; % bass rhythm
%     regOnsets=0;
%     slice2bass=1;
%     contWindow=0;
%     adjCont=0;
%     TRS=1;
%     consInts=1;
%     redRepNonBass=1;
%     redRepBass=1;
%     quant=.25;
% end
nmat(:,8)=1:numel(nmat(:,1)); % add an eighth column that's an index to the original
%rawmat=nmat; %store the raw nmat

%% create vmat
% (separate nmat into multiple nmats, one for each voice)
% nmatmin=min(nmat(:,3));
% if nmatmin==0
%     nv=max(nmat(:,3))+1; %nv=number of voices, third column of nmat is MIDI channel
% else
%     nv=max(nmat(:,3));
% end
v=unique(nmat(:,3))
nv=numel(v);
vmat{nv}=[];
pitchmean(nv)=0;
lastoffset(nv)=nan;
for i=1:nv % for loop where i is the voices 1 to n
    ind=nmat(:,3)==v(i);%+1-nmatmin; % index of nmat rows for voice i/channel i-1 (channels start with 0)
    vmat{i}=nmat(ind,:); % extract nmat rows for voice i/channel i-1
    vmat{i}(:,3)=i;
    vmat{i}(:,1)=round(vmat{i}(:,1),4); % round onset to 4th decimal place
    vmat{i}(:,1)=(floor(vmat{i}(:,1)/quant))*quant; % floor round onset to minimum quantization
    pitchmean(i)=mean(vmat{i}(:,4)); % mean pitch for voice i/channel i-1
    if numel(vmat{i}(:,1))>0
    lastoffset(i)=vmat{i}(end,1)+vmat{i}(end,2);
    end
end
[~, ind]=sort(pitchmean,'descend'); % sort by mean pitch for each voice
vmat=vmat(ind); % order voice mats by pitch height (highest will be vmat {1})

vmat

%inputnmat=vmat{sel};
if type==1
    if redRepBass==1
        %% reduce repetition in bass
        %bass=nv; % reference to bass voice (the last of chans)
        for i=numel(vmat{bass}(:,1)):-1:2 % for loop from end to beginning of vmat{bass}
            if rem(vmat{bass}(i,rrRem),1)==0 % if note is on the downbeat
                continue %skip it
            end
            if vmat{bass}(i,1)-(vmat{bass}(i-1,1)+vmat{bass}(i-1,2)) > .1 %if there is a rest before
                continue %skip it
            end
            %p1=mod(vmat{bass}(i,4),12); % pitch for note at i
            %p2=mod(vmat{bass}(i-1,4),12); % pitch for note at i-1
            p1=vmat{bass}(i,4); % pitch for note at i
            p2=vmat{bass}(i-1,4); % pitch for note at i-1
            if p1==p2 % if note at i and i-1 are the same pitch
                vmat{bass}(i-1,2)=vmat{bass}(i,1)-vmat{bass}(i-1,1)+vmat{bass}(i,2); % note i-1 absorbs note i
                vmat{bass}(i,:)=[]; % note i is deleted
            end
        end % for i loop
    end
    
    if regOnsets==1
        %bass=nv;
        %% regulate onsets in bass
        for i=numel(vmat{bass}(:,1)):-1:2
            o2=vmat{bass}(i,1); % onset for note i
            o1=vmat{bass}(i-1,1); % onset for note i-1
            if floor(o2)==o2 % if note i is already on a beat
                continue % skip it
            elseif floor(o2)<=o1 % if note i-1 is between note i and the beat
                continue
            else
                vmat{bass}(i,1)=floor(o2); % move note i to the beat
                vmat{bass}(i,2)=vmat{bass}(i,2)+rem(o2,1); % add the difference to its duration
            end
        end
        if rem(vmat{bass}(1,1),1)~=0
            vmat{bass}(1,1)=floor(vmat{bass}(1,1)); % move note i to the beat
            vmat{bass}(1,2)=vmat{bass}(1,2)+rem(vmat{bass}(1,1),1); % add the difference to its duration
        end
    end
end
%check138=vmat{sel}
%% reduce repetition in non-bass voices
if redRepNonBass==1
    %for x=1:numel(vmat)
        for i=numel(vmat{sel}(:,1)):-1:2
            if rem(vmat{sel}(i,1),rrRem)==0 % if on the beat
                continue % skip
            end
            if vmat{sel}(i,1)-(vmat{sel}(i-1,1)+vmat{sel}(i-1,2)) > .1 % if rest before
                continue % skip
            end
            p1=mod(vmat{sel}(i,4),12);
            p2=mod(vmat{sel}(i-1,4),12);
            if p1==p2
                vmat{sel}(i-1,2)=vmat{sel}(i,1)-vmat{sel}(i-1,1)+vmat{sel}(i,2);
                %vmat{sel}(i-1,9)=vmat{sel}(i,9)+vmat{sel}(i-1,9);
                vmat{sel}(i,:)=[];
            end
        end
    %end
end
if type==1
    if slice2bass==1
        %% slice to bass
        for i=numel(vmat{sel}(:,1)):-1:1
            ons=vmat{sel}(i,1);
            offs=vmat{sel}(i,1)+vmat{sel}(i,2);
            bind{i}=find(vmat{bass}(:,1)>ons & vmat{bass}(:,1)<offs);
            if numel(bind{i})>0
                vmat{sel}(i,2)=vmat{bass}(bind{i}(1),1)-vmat{sel}(i,1);
                clearvars newline
                for j=1:numel(bind{i})
                    newline(j,:)=vmat{sel}(i,:);
                    newline(j,1:2)=vmat{bass}(bind{i}(j),1:2);
                end
                vmat{sel}=[vmat{sel};newline];
            end
        end
        [~,ind]=sort(vmat{sel}(:,1));
        vmat{sel}=vmat{sel}(ind,:);
        %bassOns=unique(vmat{bass}(:,1));
        orphans=vmat{sel};
        for i=1:numel(vmat{bass}(:,1))
            ind=find(orphans(:,1)>=vmat{bass}(i,1) & orphans(:,1)<(vmat{bass}(i,1)+vmat{bass}(i,2)));
            orphans(ind,:)=[];
        end
    end
end

%% search for rare intervals (6 and 10) and consonant intervals
if TRS==1
    TRSmat=[1,1,1,1,1,1,1,1];
    %i=bass;
    %for j=2:numel(vmat)
    %j=sel;
        for k=1:numel(vmat{bass}(:,1))-1
            breakcheck=0;
            oa=vmat{bass}(k,1);
            oa2=vmat{bass}(k+1,1);
            pa=vmat{bass}(k,4);
            bind{k}=find(vmat{sel}(:,1)>=oa & vmat{sel}(:,1)<oa2);
            for x=1:numel(bind{k})
                pb=vmat{sel}(bind{k}(x),4);
                if mod(pb-pa,12)==6
                    %                     try
                    %                         oa3=vmat{bass}(k+2,1);
                    %                     catch
                    %                         oa3=vmat{bass}(k+1,1)+vmat{bass}(k+1,2);
                    %                     end
                    bind{k+1}=find(vmat{sel}(:,1)>=oa2 & vmat{sel}(:,1)<=oa2+2);
                    %intmat(end+1,:)=[vmat{sel}(bind{k}(x),:),ints1(l),pa];
                    for y=1:numel(bind{k+1})
                        pb2=vmat{sel}(bind{k+1}(y),4);
                        if pb+1==pb2
                            ind=find(vmat{bass}(:,1)==vmat{sel}(bind{k+1}(y),1));
                            if isempty(ind)==0
                                pa2=vmat{bass}(ind(1),4);
                                if pa-1==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                elseif pa-2==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                end
                            end
                        elseif pb-1==pb2
                            ind=find(vmat{bass}(:,1)==vmat{sel}(bind{k+1}(y),1));
                            if isempty(ind)==0
                                pa2=vmat{bass}(ind(1),4);
                                if pa+1==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                end
                            end
                        elseif pb-2==pb2
                            ind=find(vmat{bass}(:,1)==vmat{sel}(bind{k+1}(y),1));
                            if isempty(ind)==0
                                pa2=vmat{bass}(ind(1),4);
                                if pa+1==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                end
                            end
                        end
                    end
                elseif mod(pb-pa,12)==10
                    %                     try
                    %                         oa3=vmat{bass}(k+2,1);
                    %                     catch
                    %                         oa3=vmat{bass}(k+1,1)+vmat{bass}(k+1,2);
                    %                     end
                    bind{k+1}=find(vmat{sel}(:,1)>=oa2 & vmat{sel}(:,1)<=oa2+2);
                    %intmat(end+1,:)=[vmat{sel}(bind{k}(x),:),ints1(l),pa];
                    for y=1:numel(bind{k+1})
                        pb2=vmat{sel}(bind{k+1}(y),4);
                        %pa2=vmat{bass}(k+1,4);
                        if pb-1==pb2
                            ind=find(vmat{bass}(:,1)==vmat{sel}(bind{k+1}(y),1));
                            if isempty(ind)==0
                                pa2=vmat{bass}(ind(1),4);
                                if pa+5==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                elseif pa-7==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                end
                            end
                        elseif pb-2==pb2
                            ind=find(vmat{bass}(:,1)==vmat{sel}(bind{k+1}(y),1));
                            if isempty(ind)==0
                                pa2=vmat{bass}(ind(1),4);
                                if pa+5==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                elseif pa-7==pa2
                                    TRSmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                                    TRSmat(end,1:2)=vmat{bass}(k,1:2);
                                    TRSmat(end+1,:)=vmat{sel}(bind{k+1}(y),:);
                                    TRSmat(end,1:2)=vmat{bass}(ind(1),1:2);
                                    %temp=[bind{k}; bind{k+1}];
                                    %vmat{sel}(temp,:)=[];
                                    breakcheck=1;
                                    break
                                end
                            end
                        end
                    end
                end
                if breakcheck==1
                    break
                end
            end
        end
        TRSmat(1,:)=[];
        for k=1:2:numel(TRSmat(:,1))
            ind=find(vmat{sel}(:,1)>=TRSmat(k,1) & vmat{sel}(:,1)<TRSmat(k+1,1)+TRSmat(k+1,2));
            vmat{sel}(ind,:)=[];
        end
    
end
if consInts==1
    consmat=[1,1,1,1,1,1,1,1];
    ints1 = [0,3,4,7,8,9];
    
    for k=1:numel(vmat{bass}(:,1))
        %breakcheck=0;
        oa=vmat{bass}(k,1);
        if k==numel(vmat{bass}(:,1))
            oa2=vmat{bass}(k,1)+vmat{bass}(k,2);
        else
            oa2=vmat{bass}(k+1,1);
        end
        pa=vmat{bass}(k,4);
        bind{k}=find(vmat{sel}(:,1)>=oa & vmat{sel}(:,1)<oa2);
        for x=1:numel(bind{k})
            pb=vmat{sel}(bind{k}(x),4);
            for l=1:numel(ints1)
                if mod(pb-pa,12)==ints1(l)
                    consmat(end+1,:)=vmat{sel}(bind{k}(x),:);
                end
                
            end
            
        end
    end
    consmat(1,:)=[];
    vmat{sel}=consmat;
end

%if pointsOnOff==1
    %% assign markedness
    %i=sel;
    vmat{sel}(:,9)=0;
    if TRS==1
        if type==2
            TRSmat(:,9)=varParam;
        else
            TRSmat(:,9)=5;
        end
        vmat{sel}=[vmat{sel};TRSmat];
        [~,ind]=sort(vmat{sel}(:,1));
        vmat{sel}=vmat{sel}(ind,:);
        TRSmat(:,9)=[];
    end
    
    %Pitch
    if any(CLP)==1
        CL=CT_makeContComCLSnansum(vmat{sel}(:,4),2);
        for j=3:numel(vmat{sel}(:,1))-2
            for k=1:5
                if CL(j)==5-k
                    vmat{sel}(j,9)=vmat{sel}(j,9)+CLP(k);
                    break
                end
            end
        end
    end
    
    %Duration
    if any(DLP)==1
        DL=CT_makeContComCLSnansum(vmat{sel}(:,2),2);
        for j=3:numel(vmat{sel}(:,1))-2
            for k=1:5
                if DL(j)==5-k
                    vmat{sel}(j,9)=vmat{sel}(j,9)+DLP(k);
                    break
                end
            end
        end
    end
    
    if DPthresh>0
        if DP>0
            for j=1:numel(vmat{sel}(:,1))
                if vmat{sel}(j,2)>=DPthresh
                    vmat{sel}(j,9)=vmat{sel}(j,9)+DP;
                end
            end
        end
    end
    
    %Onsets
    %isrem3_1 = rem(vmat{sel}(:,1)+1, 3) == 0;
    if sum(remP)>0
        for k=1:4
            if remP(k)>0
                isrem = rem(vmat{sel}(:,1), k) == 0;
                for j=1:numel(vmat{sel}(:,1))
                    if isrem(j)==1 % downbeat in 4/4
                        vmat{sel}(j,9)=vmat{sel}(j,9)+remP(k);
                    end
                end
            end
        end
    end
    
    if upbeat==1
        for k=3:4
            if remP(k)>0
                isrem = rem(vmat{sel}(:,1)+1, k) == 0;
                for j=1:numel(vmat{sel}(:,1))
                    if isrem(j)==1 % downbeat in 4/4
                        vmat{sel}(j,9)=vmat{sel}(j,9)+remP(k);
                    end
                end
            end
        end
    end
    
    
    %% Add points for adjacent contiquity
    if adjCont==1
        %i=sel;
        last1=[];
        last2=[];
        for j=2:numel(vmat{sel}(:,1))
            
            pa=vmat{sel}(j-1,4);
            pb=vmat{sel}(j,4);
            if pb-pa <= bonusint && pb-pa>0
                if isempty(last2)==0
                    vmat{sel}(j-numel(last2):j-1,9)=vmat{sel}(j-numel(last2):j-1,9)+sum(last2);
                end
                last2=[];
                if isempty(last1)==1
                    last1(end+1)=0;
                    last1(end+1)=adjContBonus;
                else
                    last1(end+1)=adjContBonus;
                end
                if j==numel(vmat{sel}(:,1))
                    vmat{sel}(j-numel(last1)+1:j,9)=vmat{sel}(j-numel(last1)+1:j,9)+sum(last1);
                end
            elseif 12-(pb-pa) <= bonusint && 12-(pb-pa)>0
                if isempty(last2)==0
                    vmat{sel}(j-numel(last2):j-1,9)=vmat{sel}(j-numel(last2):j-1,9)+sum(last2);
                end
                last2=[];
                if isempty(last1)==1
                    last1(end+1)=0;
                    last1(end+1)=adjContBonus;
                else
                    last1(end+1)=adjContBonus;
                end
                if j==numel(vmat{sel}(:,1))
                    vmat{sel}(j-numel(last1)+1:j,9)=vmat{sel}(j-numel(last1)+1:j,9)+sum(last1);
                end
            elseif -(pb-pa) <= bonusint && -(pb-pa)>0
                if isempty(last1)==0
                    vmat{sel}(j-numel(last1):j-1,9)=vmat{sel}(j-numel(last1):j-1,9)+sum(last1);
                end
                last1=[];
                if isempty(last2)==1
                    last2(end+1)=0;
                    last2(end+1)=adjContBonus;
                else
                    last2(end+1)=adjContBonus;
                end
                if j==numel(vmat{sel}(:,1))
                    vmat{sel}(j-numel(last2)+1:j,9)=vmat{sel}(j-numel(last2)+1:j,9)+sum(last2);
                end
            elseif 12+(pb-pa) <= bonusint && 12+(pb-pa)>0
                if isempty(last1)==0
                    vmat{sel}(j-numel(last1):j-1,9)=vmat{sel}(j-numel(last1):j-1,9)+sum(last1);
                end
                last1=[];
                if isempty(last2)==1
                    last2(end+1)=0;
                    last2(end+1)=adjContBonus;
                else
                    last2(end+1)=adjContBonus;
                end
                if j==numel(vmat{sel}(:,1))
                    vmat{sel}(j-numel(last2)+1:j,9)=vmat{sel}(j-numel(last2)+1:j,9)+sum(last2);
                end
            else
                if isempty(last1)==0
                    vmat{sel}(j-numel(last1):j-1,9)=vmat{sel}(j-numel(last1):j-1,9)+sum(last1);
                elseif isempty(last2)==0
                    vmat{sel}(j-numel(last2):j-1,9)=vmat{sel}(j-numel(last2):j-1,9)+sum(last2);
                end
                last1=[];
                last2=[];
            end
        end
        
    end
    
    
    %% Add bonus for contiguity with high-ranking notes
    clear bind
    %i=sel;
        ind=find(vmat{sel}(:,9)>=contthresh);
        %numel(ind)
        for j=1:numel(ind)
            oa=vmat{sel}(ind(j),1);
            pa=vmat{sel}(ind(j),4);
            %         oafloor=floor(oa*2)/2;
            %         [~, index] = min(abs(vmat{bass}(:,1)-oafloor));
            if contWindow==0
                try
                    index=find(vmat{bass}(:,1)<=oa);
                    index=index(end);
                catch
                    continue
                end
                try
                    mino(j)=vmat{bass}(index-1,1);
                catch
                    mino(j)=vmat{bass}(index,1);
                end
                mino(j);
                try
                    maxo(j)=vmat{bass}(index+2,1);
                catch
                    %index
                    try
                        maxo(j)=vmat{bass}(index+1,1)+vmat{bass}(index+1,2);
                    catch
                        maxo(j)=vmat{bass}(index,1)+vmat{bass}(index,2);
                    end
                end
            else
                oafloor=floor(oa);
                mino(j)=oafloor-contWindow;
                maxo(j)=oafloor+1+contWindow;
            end
            bind{j}=find(vmat{sel}(:,1)>=mino(j) & vmat{sel}(:,1)<=maxo(j));
            for x=1:numel(bind{j})
                
                if bind{j}(x)==ind(j)
                    continue
                end
                pb=vmat{sel}(bind{j}(x),4);
                if abs(pb-pa) <= bonusint
                    if abs(pb-pa)>0
                        vmat{sel}(bind{j}(x),9)=vmat{sel}(bind{j}(x),9)+contbonus;
                        %             elseif abs(pb-pa) >= penaltyint
                        %                 vmat{sel}(bind,9)=vmat{sel}(bind,9)+contpenalty;
                    end
                elseif 12-abs(pb-pa) <= bonusint
                    if 12-abs(pb-pa)>0
                        vmat{sel}(bind{j}(x),9)=vmat{sel}(bind{j}(x),9)+contbonus;
                        %             elseif abs(pb-pa) >= penaltyint
                        %                 vmat{sel}(bind,9)=vmat{sel}(bind,9)+contpenalty;
                    end
                end
            end
        end
 test=vmat{sel}       
    %% reduction section
    if type==1
        %% find the max valued soprano note for each bass note
        clear bind
        for i=1:numel(vmat{bass}(:,1))
            if i==numel(vmat{bass}(:,1))
                t375=vmat{bass}(i,1);
                t376=vmat{bass}(i,2);
                bind{i}=find(vmat{sel}(:,1)>=vmat{bass}(i,1) & vmat{sel}(:,1)<(vmat{bass}(i,1)+vmat{bass}(i,2)));
            else
                bind{i}=find(vmat{sel}(:,1)>=vmat{bass}(i,1) & vmat{sel}(:,1)<vmat{bass}(i+1,1));
                
            end
            [~,ind]=max(vmat{sel}(bind{i},9));
            %    try
            if isempty(ind)==0
                vmat{sel}(bind{i}(ind(1)),1:2)=vmat{bass}(i,1:2);
                
                %    catch
                %    end
                
                bind{i}(ind)=[];
                vmat{sel}(bind{i},:)=[];
            end
        end
    elseif type==2
        %% throw out notes under a certain threshold
        %varparam is threshold
        ind=vmat{sel}(:,9)<varParam;
        vmat{sel}(ind,:)=[];
        try
        for i=1:numel(vmat{bass}(:,1))-1
            
            bind{i}=find(vmat{sel}(:,1)>=vmat{bass}(i,1) & vmat{sel}(:,1)<vmat{bass}(i+1,1));
            [minval,ind]=min(vmat{sel}(bind{i},1));
            try
                vmat{sel}(bind{i}(ind),1)=vmat{bass}(i,1);
                vmat{sel}(bind{i}(ind),2)=vmat{sel}(bind{i}(ind),2)...
                    +vmat{sel}(bind{i}(ind),1)-vmat{bass}(i,1);
            catch
            end
            %bind{i}(ind)=[];
            %vmat{sel}(bind{i},:)=[];
        end
        catch
        end
        
    elseif type==3
        %% sample at a given rhythmic interval
        %varparam is sampling frequency in beats
        clear bind
        endoff=vmat{sel}(end,1)+vmat{sel}(end,2);
        int=floor(endoff/varParam);
        for i=0:int
            %i*varparam
            bind{i+1}=find(vmat{sel}(:,1)>=i*varParam & vmat{sel}(:,1)<(i+1)*varParam);
            %temp=bind{i}
            [~,ind]=max(vmat{sel}(bind{i+1},9));
            try
                vmat{sel}(bind{i+1}(ind),1:2)=[i*varParam, varParam];
            catch
            end
            bind{i+1}(ind)=[];
            vmat{sel}(bind{i+1},:)=[];
        end
    end
%end

%% combine into a single nmat (newnmat) and export as midi
% inddelete=find(vmat{sel}(:,9)<2);
% vmat{sel}(inddelete,:)=[];


%vmatold=vmat;
%clean up selected voice
%for j=2:numel(vmat)

   % if pointsOnOff==1
        vmat{sel}(:,9)=[];
   % end
    if TRS==1
        vmat{sel}=[vmat{sel};TRSmat];
    end
    if type==1
        if slice2bass==1
            vmat{sel}=[vmat{sel};orphans];
        end
    end
    [~, ind]=sort(vmat{sel}(:,1));
    vmat{sel}=vmat{sel}(ind,:);
    for i=1:numel(vmat{sel}(:,1))-1
        if vmat{sel}(i,1)+vmat{sel}(i,2)~=vmat{sel}(i+1,1)
            vmat{sel}(i,2)=vmat{sel}(i+1,1)-vmat{sel}(i,1);
        end
    end
    vmat{sel}(end,2)=lastoffset(sel)-vmat{sel}(end,1);
%end
newnmat=[1,1,1,1,1,1,1,1];

for i=1:nv
    %ind=vmat{i}(:,9)<4;
    %vmat{i}(ind,:)=[];
    
    %     for j=1:numel(vmat{i}(:,1))-1
    %         vmat{i}(j,2)=vmat{i}(j+1,1)-vmat{i}(j,1);
    %     end
    %     vmat{i}(:,3)=vmat{i}(:,3);

    vmat{i}(:,6:7)=vmat{i}(:,1:2)/2;
    newnmat=[newnmat;vmat{i}];
end
newnmat(1,:)=[];
nmat=newnmat;
    onsets=nmat(:,1);
    [~, ind]=sort(onsets);
    nmat=nmat(ind,:);

for i=numel(nmat(:,2)):-1:1
    if nmat(i,2)<.01
        nmat(i,:)=[];
    end
end

nmat(:,8)=[];
end