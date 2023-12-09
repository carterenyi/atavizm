function [r,p,CL,nmat]=searchAndRankSimplePoly7(nmat,type,cmin,in)

%nmat: is a nx7 matrix converted from midi data use Schutte's nmat2midi
%type: is 1=pitch algo; 2=rhythm algo; 3=pitch and rhythm algo
%cmin: is minimum cardinality for a pattern string

%CAUTION:
%1. this is only for monophonic pieces
%2. does not work with human playback settings (turn off in Finale or Sibelius)

if nargin < 3 % if number of arguments in is less than three
    cmin=5; % set minimum cardinality to 5 notes if no cmin set in call
end

try
    voiceMax=in.voiceMax;
catch
        voiceMax=0;
end

if nargin==4
    cmax=in.cmax;
    minRec=in.minRec;
    if in.rest==1
        norest=0;
    else
        norest=1;
    end
else
cmax=100; % maximum cardinality for pattern string if 50 notes
minRec=2;
norest=1;
end
usetime=1;
degrees=2; % use two degrees of adjacency in CT_makeContCom
child=0;

pitches=nmat(:,4); % extract pitch string as an array (single column matrix)
pitches=pitches'; % make it perpendicular (horizontal instead of vertical array)



onsets=nmat(:,1);

if nargin==1
    type=3;
end
if type>1 || in.PTCLS==3
    contcom=CT_makeContCom(pitches,degrees); % convert it to a continuous contour matrix
    inds=[];
    if in.varParam==1
        
        for i=numel(pitches):-1:2
            if contcom(:,i)==contcom(:,i-1)
                inds(end+1)=i;
            end
        end
    end
    
    CL=nansum(contcom); % sum each column to make it "contour levels" (a single row horizontal array)
         durs=nmat(:,1); % extract beat onsets as string based on midi data
        durs=durs(2:end)-durs(1:end-1); % convert it to interonset durations by subtracting adjacent onsets
        durs(end+1)=nmat(end,2); % add the last note duration for a complete set of durs   
    if type>1

        contcom=CT_makeContCom(durs,1); % convert it to a continuous contour matrix
        DCL=nansum(contcom); % sum each column to make it "contour levels" (a single row horizontal array)
    end
    if isempty(inds)==0
        CL(inds)=[];
        pitches(inds)=[];
        
        nmat(inds,:)=[];
        if type>1
            DCL(inds)=[];
        end
    end
    CL(isnan(pitches))=nan;
    if type>1
        DCL(isnan(pitches))=nan;
    end
else
    inp=pitches;
    if in.PTCLS==2
        cmin=cmin-1;
        cmax=cmax-1;
        inp=inp(2:end)-inp(1:end-1);
        inp(end+1)=nan;
        
        if in.varParam==1
            inp=spec2genComplementary(inp);
        end
        
%     elseif in.PTCLS==3
%         inp=CT_makeContComCLSnansum(inp,2);
    elseif in.PTCLS==4
        cmin=cmin-1;
        cmax=cmax-1;
        inp=CT_makeContComCLSnansum(inp,1);
        inp(end+1)=nan;
    end
    inp(isnan(pitches))=nan;
    CL=inp;
end


%% determine type of algorithm
if type == 1
    CL=[CL;CL];
elseif type == 2
    CL=[DCL;DCL];
elseif type == 3
    CL=[CL;DCL];
end
for n=cmin:cmax % the range of cardinalities from cmin to cmax
    clearvars segments segmentu segmentucount segmentuind temp
    
    %create a cell array with all possible segments from cmin to cmax
    for i=1:numel(pitches)-n+1
        segments{i}=CL(:,i:i+n-1);
        
        onsets1=onsets(i);
        onsets2=onsets(i+n-1);
        if onsets1>onsets2
            segments{i}=0;
            continue
        end
        
        if voiceMax>0
           chantest=nmat(i:i+n-1,3); 
           if max(chantest)>voiceMax
               segments{i}=0;
               continue
           end
        end
        
        if norest==1
            test=isnan(segments{i});
            if sum(sum(test))>0
                segments{i}=0;
                continue
            end
        else
            test=isnan(segments{i});
            if sum(sum(test))>0
                restval=[];
                test2=sum(test);
                for j=1:numel(test2)
                    if test2(j)>0
                        restval(end+1)=durs(i+j-1);
                    end
                end
                if max(restval)>=in.maxRV
                segments{i}=0;
                continue
                end
            end
            
        end
        
%         chantest=nmat(i:i+n-1,3);
%         if numel(unique(chantest))>1
%             segments{i}=0;
%             continue
%         end    
    end
    
    
    %     %create a cell array with all possible segments from cmin to cmax
    %     for i=3:numel(pitches)-n+1-2 %3: and -2 added to offset +2/-2 degrees
    %         segments{i}=CL(:,i:i+(n-4)-1); % four added to offset +2/-2 degrees
    %     end
    %
    %find out how many unique segments there are out of all segments found
    [segmentu, ~ ,idx2] = uniquecell(segments);
    
    %check to see if cardinality saturation is reached
    %(i.e. only one instance of each unique segment)
    if numel(segmentu)==numel(segments) % number of segments equals number of unique segments
        break % do not go beyond this "n" (cardinality)
    end
    
    
    for i=numel(segmentu):-1:1
        if i==numel(segmentu)
            segind{i}=0;
        end
        if segmentu{i}==0
            segmentu(i)=[];
            segind(i)=[];
            continue
        end
        ind=find(idx2==i);
        segind{i}=ind;
        if numel(ind)<minRec
            segind(i)=[];
        end

    end
    
    clear segcount
    %sort from the highest number of instances to the lowest number for
    %this cardinality (n)
    if numel(segind) > 0
        for i=1:numel(segind)
            segcount(i)=numel(segind{i});
        end
        [~, SortInd]=sort(segcount,'descend');
        %numel(SortInd)
        segind=segind(SortInd);
    end

    p(n).segind=segind;
end


for n=cmin:numel(p)
    %segind=p(n).segind;
    
    
    %     ind=p(n).segind;
    %     for i=numel(ind):-1:1
    %         if numel(ind{i})<2
    %             p(n).segind(i)=[];
    %         end
    %     end
    
    for i=1:numel(p(n).segind)
        ind=p(n).segind{i};
        
        %% remove overlap
        for j=numel(ind)-1:-1:2
            if j==numel(ind)
                continue
            end
            if ind(j)+n+1>=ind(j+1)
                if ind(j-1)+n+1>=ind(j)
                    if ind(j-1)+n+1<ind(j+1)
                        ind(j)=[];
                    elseif ind(j-1)+n+1>=ind(j+1)
                        ind(j:j+1)=[];
                    end
                elseif ind(j-1)+n+1<ind(j)
                    ind(j+1)=[];
                end
            elseif ind(j-1)+n+1>=ind(j)
                ind(j)=[];
            end
        end
        p(n).segind{i}=ind;
        
    end
    
    
end

%% create r (an indexing structure for plotting)
%initialize storage variables
%allcov=0; % will be used for sorting based on coverage (instances x cardinality)
%r(1).seg=p(cmin).seg{1};
r(1).card=cmin;
r(1).segind=[];
r(1).segcount=0;
r(1).cov=0;
%r(1).invind=[]; % not used but present to work with arcPlot

%% move and convert everything remaining in p to r for plotting
for i=1:numel(p)
    for j=1:numel(p(i).segind)
        segind=p(i).segind{j};
        %sort by onset
        segindonset=nmat(segind,1);
        [~, SortInd]=sort(segindonset);
        segind=segind(SortInd);
        r(end+1).segind=segind; % start indicies with the nmat
        if in.PTCLS==2
            %r(end).segind=r(end).segind-1;
            r(end).card=i;
        elseif in.PTCLS==4
            %r(end).segind=r(end).segind-1;
            r(end).card=i;
        else
            r(end).card=i;
        end
       
        r(end).segcount=numel(p(i).segind{j}); % number of insances
        if usetime==1
            try
            r(end).cov=sum(nmat(segind+i,1)-nmat(segind,1));
            catch
            r(end).cov=sum(nmat(segind+i-1,1)+nmat(segind+i-1,2)-nmat(segind,1));  
            end
        else
            r(end).cov=numel(p(i).segind{j})*i; % segment coverage (cardinality X instances)
        end
    end
end
r(1)=[]; % remove initialized placeholder



%% sort by coverage
clear cov
for i=1:numel(r)
    cov(i)=r(i).cov;
end
[~, SortInd]=sort(cov,'descend'); % sort based on coverage
r=r(SortInd); % sort r based on all cov

%numel(r)



%% get all indices of notes in the nmat that are part of segments in r
for i=1:numel(r)
    clearvars temp
    temp=[];
    for j=1:numel(r(i).segind)
        temp=[temp,r(i).segind(j):r(i).segind(j)+r(i).card-1];
    end
    r(i).inds=temp;
end

%% remove rows in r that have all the inds (inclusive of all events in nmat)
nr=numel(r);
for i = nr:-1:1
    b=r(i).inds;
    for j=i-1:-1:1
        a=r(j).inds;
        %if r(i).segcount<=r(j).segcount
        if all(ismember(b,a))==1
            r(i)=[];
            break
        end
        %end
    end
end
%% sort by coverage
clear cov
for i=1:numel(r)
    cov(i)=r(i).cov;
end
[~, SortInd]=sort(cov,'descend'); % sort based on coverage
r=r(SortInd); % sort r based on all cov

%% see if subsegment
clear card
for i=1:numel(r)
    card(i)=r(i).card;
end
[~, SortInd]=sort(card,'descend'); % sort based on coverage
r=r(SortInd); % sort r based on all card

% for i=numel(r):-1:2
%     segstarta=r(i).segind(1);
%     segenda=r(i).segind(1)+r(i).card-1;
%     for j=1:i-1
%         segstartb=r(j).segind(1);
%         if segstarta>=segstartb
%             segendb=r(j).segind(1)+r(j).card-1;
%             if segenda<=segendb
%                 r(i)=[];
%                 break
%             end
%         end
%         
%     end
%     
% end

%% remove rows in r that have all the same seginds (segment start indices referring to nmat)
% for i=numel(r):-1:2
%     breakit=0;
%     b=r(i).segind;
%     for j=i-1:-1:1
%         a=r(j).segind;
%         for k=1:5
%             if all(ismember(b+3-k,a))==1
%                 % if r(i).card<=r(j).card
%                 r(i)=[];
%                 breakit=1;
%                 break
%                 % end
%             end
%         end
%         if breakit==1
%             break
%         end
%     end
% end

%% expand up to +2/-2
if in.PTCLS==3 || type==2
clear cov test seg test2
%testseq=[2,2;1,2;2,1;1,1;0,1;1,0;0,0];
numel(r);
for i=1:numel(r)
 %   test=383
         %breakit=0;
        continueit=0;
    for a=1:2

        %try
            for j=1:numel(r(i).segind)
                if r(i).segind(j)-a>0
                seg{i}{j}=nmat(r(i).segind(j)-a:r(i).segind(j)+r(i).card-1,4)';
                if norest==1
                    test2=isnan(seg{i}{j});
                    if sum(sum(test2))>0
                        continueit=1;
                        break
                    end
                end
                contcom=CT_makeContCom(seg{i}{j},1); % convert it to a continuous contour matrix
                seg{i}{j}=nansum(contcom);
                end
            end
            if continueit==1
                continue
            end
            test{i}=uniquecell(seg{i});
            
            if numel(test{i})<3
                if numel(test{i})==2
                    if lev(test{i}{1},test{i}{2})<3
                        r(i).segind=r(i).segind-a;
                        r(i).card=r(i).card+a;
                        break
                    end
                else
                    r(i).segind=r(i).segind-a;
                    r(i).card=r(i).card+a;
                    break
                end
            end
        %catch
        %end
%         if breakit==1
%             break
%         end
    end
    continueit=0;
    for a=2:-1:1
        %continueit=0;
        %try
            for j=1:numel(r(i).segind)
                if r(i).segind(j)+r(i).card-1+a<=numel(nmat(:,1))
                seg{i}{j}=nmat(r(i).segind(j):r(i).segind(j)+r(i).card-1+a,4)';
                if norest==1
                    test2=isnan(seg{i}{j});
                    if sum(sum(test2))>0
                        continueit=1;
                        break
                    end
                end
                contcom=CT_makeContCom(seg{i}{j},1); % convert it to a continuous contour matrix
                seg{i}{j}=nansum(contcom);
                end
            end
            if continueit==1
                continue
            end
            test{i}=uniquecell(seg{i});
            if numel(test{i})<3
                if numel(test{i})==2
                    if lev(test{i}{1},test{i}{2})<3
                    r(i).card=r(i).card+a;
                                    break
                    end
                else
                r(i).card=r(i).card+a;
                break
                end
            end
       % catch
       % end
    end
    cov(i)=r(i).cov;
    card(i)=r(i).card;
end
[~,ind]=sort(cov,'descend');
r=r(ind);
end



% give a card for each segind and add new features
for i=1:numel(r)
        onsets=nmat(r(i).segind,1);
    [~,sortInd]=sort(onsets);
    r(i).segind=r(i).segind(sortInd);
    card=r(i).card;
    r(i).card=card*ones(1,numel(r(i).segind)); % cardinality of segment
    r(i).nmatSR=nmat;
    r(i).seg=CL(1,r(i).segind:r(i).segind+card-1);
    r(i).type=type;
    %hello=491
    if type==1
        if  in.PTCLS==1
            r(i).name=['P [' num2str(r(i).seg) ']'];
        elseif in.PTCLS==2
            %r(i).segind=r(i).segind;
            r(i).card=r(i).card+1;
%            r(i).seg=CL(1,r(i).segind:r(i).segind+r(i).card-1);
            r(i).name=['T [' num2str(r(i).seg) ']'];
        elseif in.PTCLS==3
            r(i).name=['L [' num2str(r(i).seg) ']'];
        elseif in.PTCLS==4
            %r(i).segind=r(i).segind-1;
            r(i).card=r(i).card+1;
 %           r(i).seg=CL(1,r(i).segind:r(i).segind+r(i).card-1);
            r(i).name=['S [' num2str(r(i).seg) ']'];     
        end
    elseif type==2
        r(i).name=['D [' num2str(r(i).seg) ']'];
    elseif type==3
        r(i).name=['I [' num2str(r(i).seg) ']'];
    end
    for j=1:numel(r(i).segind)
        r(i).key(j)=nan;
        r(i).keytext{j}='';

    end
    r(i).keyaxi=r(i).key;
    r(i).opacity=.3;
    r(i).keyDisp=1;
    r(i).axi=[];
        r(i).arcType=1;
        r(i).show=1;
        r(i).arcDir=1;
end
r=rmfield(r,'inds');

% make sure no cross voices (onset greater than offset)
for i=1:numel(r)
    for j=numel(r(i).segind):-1:1
        try
        while nmat(r(i).segind(j),1)>nmat(r(i).segind(j)+r(i).card(j)-1,1)
            r(i).card(j)=r(i).card(j)-1;
        end
        catch
        end
        
    end
end

end