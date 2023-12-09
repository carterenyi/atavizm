function [r,nmat]=searchAndRankSchema(nmat,in)

minRec=in.minRec;
cmin=in.cmin;
cmax=in.cmax;
schsz=cmin:cmax;
%in.redo;
contOnOff=in.contOnOff;
allowSkips=in.allowSkips;
sto=in.sto; % stage offset
if isempty(sto)==1
    in.redo=1;
end
do=1/2; %% maximum displacement dissonance offset in beats (inter-onset-interval)
TorS=0; % t=transposition; s=syntagmatic (simple contour)
slsz=1/4; %slice size
CL4=1;
CL3=1;
CL2=0;
CL1=1;
CL0=1;
DL4=1;
DL3=1;
DL2=0;
DL1=0;
DL0=0;
rem4=0;
rem3=0;
rem3_1=0;
rem2=1;
rem1=1;
rareint=0;
consint=0;
if in.contOnOff==1
    contthresh=3;
    bonusint=2;
    contbonus=1;
    penaltyint=8;
    contpenalty=-1;
else
    contthresh=3;
    bonusint=2;
    contbonus=0;
    penaltyint=8;
    contpenalty=0;
end
%meter=4;
repred=1;
restThreshold=.1;
pointThreshold=3;
usetime=1;
combinePoints=0;
%allowSkips=1;

if in.redo==0
    %title='Fugue in c minor';
    %filename='Fugue-BWV-847.mid';
    % title='Mozart Sonata K545';
    % filename='Mozart_piano_sonata_545_mvmt1.mid';
    % stringName{1}='Prinner';
    %in.overlap=1;
    %title=filename;
    
    %nmat=midi2nmat(filename);
    rawmat=nmat;
    nmat(:,8)=1:numel(nmat(:,1));
    ind=find(isnan(nmat(:,4)));
    nmat(ind,:)=[];
    
    %%create vmat
    nv=max(nmat(:,3)); %nv=number of voices
    for x=1:nv
%         if min(nmat(:,3))==0
%             I{x}=find(nmat(:,3)==x-1); % index of nmat rows for that voice
%         else
            I{x}=find(nmat(:,3)==x);
%         end
        vmat{x}=nmat(I{x},:);
        vmat{x}(:,1)=round(vmat{x}(:,1),2);
        vmat{x}(:,2)=round(vmat{x}(:,2),2);
        if repred==1
            for i=numel(vmat{x}(:,1)):-1:2
                if rem(vmat{x}(i,1),sto)==0
                    continue
                end
                if vmat{x}(i,1)-(vmat{x}(i-1,1)+vmat{x}(i-1,2)) > restThreshold
                    continue
                end
                p1=mod(vmat{x}(i,4),12);
                p2=mod(vmat{x}(i-1,4),12);
                if p1==p2
                    vmat{x}(i-1,2)=vmat{x}(i,1)-vmat{x}(i-1,1)+vmat{x}(i,2);
                    %vmat{x}(i-1,9)=vmat{x}(i,9)+vmat{x}(i-1,9);
                    vmat{x}(i,:)=[];
                end
            end
        end
        
    end
    %vmat=vmat(3:-1:1); % sort lowest to highest
    
    %% assign markedness
    for i=1:nv
        vmat{i}(:,9)=0;
        CL=CT_makeContComCLSnansum(vmat{i}(:,4),2);
        DL=CT_makeContComCLSnansum(vmat{i}(:,2),2);
        isrem4 = rem(vmat{i}(:,1), 4) == 0;
        isrem3 = rem(vmat{i}(:,1), 2) == 0;
        isrem3_1 = rem(vmat{i}(:,1)+1, 2) == 0;
        isrem2 = rem(vmat{i}(:,1), 2) == 0;
        isrem1 = rem(vmat{i}(:,1), 1) == 0;
        
        for j=1:numel(vmat{i}(:,1))
            
            if CL(j)==4
                vmat{i}(j,9)=vmat{i}(j,9)+CL4;
            elseif CL(j)==3
                vmat{i}(j,9)=vmat{i}(j,9)+CL3;
            elseif CL(j)==1
                vmat{i}(j,9)=vmat{i}(j,9)+CL1;
            elseif CL(j)==0
                vmat{i}(j,9)=vmat{i}(j,9)+CL0;
            end
            
            if DL(j)==4
                vmat{i}(j,9)=vmat{i}(j,9)+DL4;
            elseif DL(j)==3
                vmat{i}(j,9)=vmat{i}(j,9)+DL3;
            elseif DL(j)==2
                vmat{i}(j,9)=vmat{i}(j,9)+DL2;
            end
            
            if isrem4(j)==1 % downbeat in 4/4
                vmat{i}(j,9)=vmat{i}(j,9)+rem4;
            end
            
            if isrem3(j)==1 % strong beats in 4/4
                vmat{i}(j,9)=vmat{i}(j,9)+rem3;
            end
            
            if isrem3_1(j)==1 % strong beats in 4/4
                vmat{i}(j,9)=vmat{i}(j,9)+rem3_1;
            end
            
            if isrem2(j)==1 % strong beats in 4/4
                vmat{i}(j,9)=vmat{i}(j,9)+rem2;
            end
            
            if isrem1(j)==1
                vmat{i}(j,9)=vmat{i}(j,9)+rem1;
            end
        end
    end
    %% search for rare intervals (6 and 10) and consonant intervals
    if sum(rareint+consint)>0
        ints1 = [6,10];
        ints2 = [3,4,8,9];
        for i=1:nv
            for j=1:nv
                if i==j
                    continue
                end
                %s{i*j-1}{1}=[]; %initialize storage of rare intervals
                
                for k=1:numel(vmat{i}(:,1))
                    %             if vmat{i}(k,9)<1
                    %                 continue
                    %             end
                    oa=vmat{i}(k,1);
                    pa=vmat{i}(k,4);
                    bind=find(vmat{j}(:,1)>=oa-do & vmat{j}(:,1)<=oa+do);
                    for x=1:numel(bind)
                        
                        pb=vmat{j}(bind(x),4);
                        for l=1:numel(ints1)
                            if mod(abs(pb-pa),12)==ints1(l)
                                vmat{i}(k,9)=vmat{i}(k,9)+rareint;
                            end
                        end
                        
                        for l=1:numel(ints2)
                            if mod(abs(pb-pa),12)==ints2(l)
                                %                         if k<50
                                %                             k
                                %                         pb
                                %                         pa
                                %                         ints2(l)
                                %                         vmat{i}(k,8)
                                %
                                %                         end
                                vmat{i}(k,9)=vmat{i}(k,9)+consint;
                                %                         if pb > pa
                                %                             s{i*j-1}{end+1}=[vmat{j}(bind,:);vmat{i}(k,:)];
                                %                         elseif pa > pb
                                %                             s{i*j-1}{end+1}=[vmat{i}(k,:);vmat{j}(bind,:)];
                                %                         end
                            end
                        end
                    end
                end
                %s=s{i*j-1}(2:end);
            end
        end
    end
    
    %% Add bonus and penalty for contiguity with high-ranking notes
    newnmat2=[1,1,1,1,1,1,1,1,1];
    [onsmax, ind]=max(nmat(:,1));
    off=onsmax+nmat(ind(end),2);
    
    %vmat=vmatold;
    for k=1:numel(sto)
        for i=1:nv
            rmat=vmat{i};
            ind=find(rmat(:,9)>=contthresh);
            if i==1
                indsave=ind;
            end
            for j=1:numel(ind)
                oa=rmat(ind(j),1);
                pa=rmat(ind(j),4);
                %for x=1:vmat{i}
                %% find notes before
                
                wO=floor(oa/sto(k))*sto(k); %windowOnset
                bind=find(rmat(:,1)>=wO-sto(k) & rmat(:,1)<wO);
                bind2=find(rmat(:,1)>=wO+sto(k) & rmat(:,1)<wO+2*sto(k));
                bind=[bind', bind2'];
                if i==1
                    if ind(j)==9
                        bindsave=bind;
                    end
                end
                %                if bind==ind(j)
                %                    continue
                %                end
                if numel(bind)>0
                    for l=1:numel(bind)
                        pb=rmat(bind(l),4);
                        if pb-pa~=0
                            if abs(pb-pa) <= bonusint
                                rmat(bind(l),9)=rmat(bind(l),9)+contbonus;
                            elseif abs(pb-pa) >= penaltyint
                                rmat(bind(l),9)=rmat(bind(l),9)+contpenalty;
                            end
                        end
                    end
                end
                %end
                %end
            end
            
            
            %% take maximum note within window
            
%            rmatsave{i}=rmat;
            numwin=ceil(off/sto(k)); %number of windows; sto determines window size
            blanks=[1,1,i,nan,64,1,1,0,0];
            for j=1:numwin
                start=(j-1)*sto(k);
                stop=j*sto(k);
                ind=find(rmat(:,1)>=start & rmat(:,1)<stop);
                if isempty(ind)
%                     blanks(end+1,:)=blanks(end,:);
%                     blanks(end,1)=start;
%                     blanks(end,2)=sto(k);
%                     blanks(end,6)=start/2;
%                     blanks(end,7)=sto(k)/2;
                    continue
                end
                if combinePoints==1
                    uniqPitch=unique(rmat(ind,4));
                    for z=1:numel(uniqPitch)
                        temp=find(rmat(ind,4)==uniqPitch(z));
                        points=sum(rmat(ind(temp),9));
                        rmat(ind(temp(1)),9)=points;
                    end
                end
                [val, ind2]=max(rmat(ind,9));
                rmat(ind(ind2),1)=start;
                rmat(ind(ind2),2)=sto(k);
                rmat(ind(ind2),6)=start/2;
                rmat(ind(ind2),7)=sto(k)/2;
                ind(ind2)=[];
                rmat(ind,:)=[];
            end
%             blanks(1,:)=[];
%             rmat=[rmat;blanks];
%             [~,sortInd]=sort(rmat(1,:));
%             rmat=rmat(sortInd);
            if numel(rmat(:,1))~=0
                temp=rmat(end,:);
                rmat=[rmat;temp];
                rmat(end,4)=nan;
                if allowSkips==1
                    % add odds
                    temp1=rmat(1:2:end-1,:);
                    temp1(:,2)=temp1(:,2)+temp1(:,2);
                    temp1(:,3)=temp1(:,3)+50;
                    temp1=[temp1;temp];
                    temp1(end,4)=nan;
                    % add evens
                    temp2=rmat(2:2:end-1,:);
                    temp2(:,2)=temp2(:,2)+temp2(:,2);
                    temp2(:,3)=temp2(:,3)+100;
                    temp2=[temp2;temp];
                    temp2(end,4)=nan;
                    rmat=[rmat;temp1;temp2];
                end
            end
            newnmat2=[newnmat2;rmat];
        end
    end
    newnmat2(1,:)=[];
    %temp=newnmat2;
    % [ord, ind]=sort(newnmat2(:,1)) ;
    % newnmat2=newnmat2(ind,:);
    % % M: input matrix:
    % %   1     2    3  4   5  6
    % %  [track chan nn vel t1 t2] (any more cols ignored...)
    % clear m
    % m(numel(newnmat2(:,1)),1)=1;
    % m(:,2:6)=newnmat2(:,3:7);
    % midi_new = matrix2midi(m);
    % writemidi(midi_new, 'test3.mid');
    
    %newnmat2=temp;
    
    
    nmat=newnmat2;
    %r=searchAndRank(nmat,1,4,in);
    %r=arcPlot(r,nmat,nmat,title,0,2,{'test'});
end
ints=nmat(2:end,4)-nmat(1:end-1,4);
io=nmat(2:end,1)-nmat(1:end-1,1); % interonsets
durs=nmat(1:end-1,2);

if TorS==1 % t=transposition; s=syntagmatic (simple contour)
    ints(ints<0)=-1;
    ints(ints>0)=1;
else %if TorS==0 % t=transposition; s=syntagmatic (simple contour)
    % make generic version
    ints=spec2genComplementary(ints);
    % end
end

for z=cmin:cmax
    clearvars segments segmentu segmentucount segmentuind temp seggen
    n=z-1; % determines schema length
    for i=1:numel(ints)-n+1
        segments{i}=ints(i:i+n-1);
        if sum(io(i:i+n-1))>z*durs(i)
            segments{i}=0;
            continue
        end
        % if norest==1
        if in.redo==1
            test=isnan(segments{i});
            if sum(test)>0
                segments{i}=0;
                %test=segments{i};
                
            end
        end
        % end
        
        %         chantest=nmat(i:i+n-1,3);
        %         if numel(unique(chantest))>1
        %             segments{i}=0;
        %             continue
        %         end
    end
    
    [segmentu, idx ,idx2] = uniquecell(segments);
    
    segmentucount=zeros(numel(segmentu),1);
    for i=1:length(segmentu)
        ind=find(idx2==i);
        segmentuind{i}=ind;
        
        segmentucount(i)=numel(ind);
        %         try
        %             segmentpitch{i}=pitches(segmentuind{i}(1)-2:segmentuind{i}(1)+n-1+2);
        %         catch
        %             try
        %                 segmentpitch{i}=pitches(segmentuind{i}(2)-2:segmentuind{i}(2)+n-1+2);
        %             catch
        %                 segmentpitch{i}=[];
        %             end
        %         end
    end
    
    %if in.redo==1
    for i=numel(segmentu):-1:1
        
        if segmentu{i}==0
            segmentuind(i)=[];
            segmentucount(i)=[];
            segmentu(i)=[];
        end
    end
    %end
    
    %     for i=numel(segmentucount):-1:1
    %         if segmentucount(i)<minRec
    %             segmentucount(i)=[];
    %             segment
    %         end
    %     end
    
    [segmentucount, SortInd]=sort(segmentucount,'descend');
    segmentu=segmentu(SortInd);
    segmentuind=segmentuind(SortInd);
    %     segmentpitch=segmentpitch(SortInd);
    idx=idx(SortInd);
    
    
    
    
    
    %% remove overlap
    for k=1:numel(segmentu)
        clear overlap
        segind=sort(segmentuind{k});
        %         segmentucount
        %         k
        %         segmentucount(k)
        
        overlap(segmentucount(k))=0;
        for i=1:segmentucount(k)-1
            for j=i+1:segmentucount(k)
                
                if segind(j) < segind(i)+n
                    overlap(j)=1;
                end
            end
        end
        
        ind=find(overlap>0);
        segmentuind{k}(ind)=[];
        %segmentucount(k)=numel(segmentuind{k});
    end
    p(n).segmentu=segmentu;
    p(n).segmentuind=segmentuind;
end

%% create r
r=[];
r(1).seg=p(cmin-1).segmentu{1};
r(1).segind=p(cmin-1).segmentuind{1};
r(1).segcount=numel(p(cmin-1).segmentuind{1});
r(1).cov=numel(p(cmin-1).segmentuind{1})*cmin;
%r(1).invind=[];
r(1).card=cmin;
clear seg
seg{1}=0;
for j=cmin-1:cmax-1
    for i=1:numel(p(j).segmentu)
        r(end+1).seg=p(j).segmentu{i};
        seg{end+1}=p(j).segmentu{i};
        r(end).segind=p(j).segmentuind{i};
        segind=r(end).segind;
        r(end).segcount=numel(p(j).segmentuind{i});
        if usetime==1
            %             try
            %                 r(end).cov=sum(nmat(segind+j+1,1)-nmat(segind,1));
            %             catch
            r(end).cov=sum(nmat(segind+j,1)+nmat(segind+j,2)-nmat(segind,1));
            %             end
        else
            r(end).cov=numel(p(j).segmentuind{i})*(j+1);
        end
        % r(end).invind=[];
        r(end).card=ones(1,numel(r(end).segind))*(j+1);
    end
end
r(1)=[];
seg(1)=[];


%% combine similar (generic intervals)
[segu, idx ,idx2] = uniquecell(seg);

%segmentucount=zeros(numel(segmentu),1);
for i=1:length(segu)
    ind=find(idx2==i);
    r2(i).seg=segu{i}';
    r2(i).segind=r(ind(1)).segind;
    for j=2:numel(ind)
        r2(i).segind=[r2(i).segind r(ind(j)).segind];
    end
    r2(i).segind=unique(r2(i).segind);
    segind=r2(i).segind;
    r2(i).segcount=numel(segind);
    card=numel(segu{i})+1;
    r2(i).card=ones(1,numel(segind))*card;
    if usetime==1
        %             try
        %                 r(end).cov=sum(nmat(segind+j+1,1)-nmat(segind,1));
        %             catch
        r2(i).cov=sum(nmat(segind+card-1,1)+nmat(segind+card-1,2)-nmat(segind,1));
        %             end
    else
        r2(i).cov=numel(segind)*card;
    end
    %r2(i).invind=[];
    
end
r=r2;

%     if TorS==0 % t=transposition; s=syntagmatic (simple contour)
%         s=1;
%         while s<numel(seggen)
%             for i=numel(seggen):-1:s+1
%                 if seggen{s}==seggen{i}
%                     segmentuind{s}=[segmentuind{s},segmentuind{i}];
%                     segmentucount(s)=numel(segmentuind{s});
%                     seggen(i)=[];
%                     segmentuind(i)=[];
%                     segmentucount(i)=[];
%                 end
%             end
%             s=s+1;
%         end
%         segmentu=seggen;
%     end


%% REMOVE OVERLAP insert here
clear cov count
for i=1:numel(r)
    %
    %     onsets=nmat(r(i).segind,1);
    %     [u,IA,IC]=unique(onsets);
    %     r(i).segind=r(i).segind(IA);
    %
    %     %ELIMINATE REDUNDALT RESULTS PRODUCED BY SKIPGRAM
    %     for k=1:numel(sto)
    %         onsets=nmat(r(i).segind,1);
    %         for j=numel(r(i).segind):-1:2
    %             if onsets(j)-sto(k)==onsets(j-1)
    %                 %onsets(j)
    %                 p1=nmat(r(i).segind(j):r(i).segind(j)+r(i).card(j)-1,4)';
    %                 p2=nmat(r(i).segind(j-1):r(i).segind(j-1)+r(i).card(j)-1,4)';
    %                 if mod(p1,12)==mod(p2,12)
    %                     r(i).segind(j)=[];
    %                     %r(i).card(j)=[];
    %                 end
    %             end
    %         end
    %     end
    %
    %     segind=r(i).segind;
    %     card=numel(r(i).seg)+1;
    %     r(i).card=ones(1,numel(segind))*card;
    %     r(i).segcount=numel(segind);
    %     if usetime==1
    %         r(i).cov=sum(nmat(segind+card-1,1)+nmat(segind+card-1,2)-nmat(segind,1));
    %     else
    %         r(i).cov=numel(segind)*card;
    %     end
    
    cov(i)=r(i).cov;
    count(i)=r(i).segcount;
end

ind=find(count<minRec);
r(ind)=[];
cov(ind)=[];
[~, ind]=sort(cov,'descend');
r=r(ind);



for i=1:numel(r)
    %remove exact matches within each r
    for j=numel(r(i).segind):-1:1
        for k=numel(r(i).segind):-1:j+1
            if nmat(r(i).segind(j),1)==nmat(r(i).segind(k),1)
                onsetsj=nmat(r(i).segind(j):r(i).segind(j)+r(i).card(j)-1,1);
                onsetsk=nmat(r(i).segind(k):r(i).segind(k)+r(i).card(k)-1,1);
                if onsetsk==onsetsj
                    %onsets(j)
                    p1=nmat(r(i).segind(j):r(i).segind(j)+r(i).card(j)-1,4)';
                    p2=nmat(r(i).segind(k):r(i).segind(k)+r(i).card(k)-1,4)';
                    if mod(p1,12)==mod(p2,12)
                        r(i).segind(j)=[];
                        r(i).card(j)=[];
                    end
                end
            end
        end
    end

    %card=r(i).card;
    %r(i).card=card*ones(1,numel(r(i).segind)); % cardinality of segment
    onsets=nmat(r(i).segind,1);
    [~,sortInd]=sort(onsets);
    r(i).segind=r(i).segind(sortInd);
    for j=1:numel(r(i).segind)
        r(i).key(j)=nan;
        r(i).keytext{j}='';
    end
    r(i).nmatSR=nmat;
    %r(i).seg=CL(1,r(i).segind:r(i).segind+r(i).card(1)-1);
    r(i).type=5;
    r(i).name=['GInts [' num2str(r(i).seg) ']'];
        r(i).keyaxi=r(i).key;
    r(i).keyDisp=[];
    r(i).axi=[];
        r(i).opacity=.3;
    r(i).arcType=[];
    r(i).show=1;
    
end
%rmfield(r,'inds');