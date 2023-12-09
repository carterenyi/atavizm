function [r,p,nmat]=searchAndRankSets(nmat,cmin,in)

%nmat: is a nx7 matrix converted from midi data use Schutte's nmat2midi
%type: is 1=pitch algo; 2=rhythm algo; 3=pitch and rhythm algo
%cmin: is minimum cardinality for a pattern string

%CAUTION:
%1. this is only for monophonic pieces
%2. does not work with human playback settings (turn off in Finale or Sibelius)

if nargin < 2 % if number of arguments in is less than three
    cmin=5; % set minimum cardinality to 5 notes if no cmin set in call
end

try
    voiceMax=in.voiceMax;
catch
        voiceMax=0;
end

if nargin==3
    cmax=in.cmax;
    minRec=in.minRec;
    norest=in.rest;
    if norest==1
        norest=0;
    else
        norest=1;
    end
else
cmax=50; % maximum cardinality for pattern string if 50 notes
minRec=2;
norest=1;
end
usetime=0;
degrees=2; % use two degrees of adjacency in CT_makeContCom
child=0;

pitches=nmat(:,4); % extract pitch string as an array (single column matrix)
pitches=pitches'; % make it perpendicular (horizontal instead of vertical array)
onsets=nmat(:,1);
% contcom=CT_makeContCom(pitches,degrees); % convert it to a continuous contour matrix
% CL=nansum(contcom); % sum each column to make it "contour levels" (a single row horizontal array)
% 
% CL(isnan(pitches))=nan;
% 
% if nargin==1
%     type=3;
% end
% if type>1
%     durs=nmat(:,6); % extract beat onsets as string based on midi data
%     durs=durs(2:end)-durs(1:end-1); % convert it to interonset durations by subtracting adjacent onsets
%     durs(end+1)=nmat(end,7); % add the last note duration for a complete set of durs
%     contcom=CT_makeContCom(durs,1); % convert it to a continuous contour matrix
%     DCL=nansum(contcom); % sum each column to make it "contour levels" (a single row horizontal array)
%     DCL(isnan(pitches))=nan;
% end
% 
% 
% %% determine type of algorithm
% if type == 1
%     CL=[CL;CL];
% elseif type == 2
%     CL=[DCL;DCL];
% elseif type == 3
%     CL=[CL;DCL];
% end

for n=cmin:cmax % the range of cardinalities from cmin to cmax
    clearvars segments segmentu segmentucount segmentuind temp
    
    %create a cell array with all possible segments from cmin to cmax
    for i=1:numel(pitches)-n+1
        segments{i}=pitches(:,i:i+n-1);
        
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
        [segments{i},nf,t,t_loc]=primeform(segments{i});
        %segments{i}=prime
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
            segmentu(i)=[];
            segind(i)=[];
        end

    end
    
    clear segcount
    %sort from the highest number of instances to the lowest number for
    %this cardinality (n)
    if numel(segind) > 0
        segcount(i)=0;
        for i=1:numel(segind)
            segcount(i)=numel(segind{i});
        end
        [~, SortInd]=sort(segcount,'descend');
        %numel(SortInd)
        segind=segind(SortInd);
        segmentu=segmentu(SortInd);
    end
   
    try
        segind(6:end)=[];
    catch
    end
    p(n).segind=segind;
    p(n).seg=segmentu;
    %    p(n).segcov=segmentucov;
end


for n=cmin:numel(p)
    %segind=p(n).segind;
    
    
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
r(1).seg=p(cmin).seg{1};
r(1).card=cmin;
r(1).segind=p(cmin).segind{1};
r(1).segcount=numel(p(cmin).segind{1});
r(1).cov=numel(p(cmin).segind{1})*cmin;
%r(1).invind=[]; % not used but present to work with arcPlot
allSegs{1}=p(cmin).seg{1};

%% move and convert everything remaining in p to r for plotting
for i=1:numel(p)
    for j=1:numel(p(i).segind)
        segind=p(i).segind{j};
        %sort by onset
        segindonset=nmat(segind,1);
        [~, SortInd]=sort(segindonset);
        segind=segind(SortInd);
        r(end+1).segind=segind; % start indicies with the nmat
        %r(end).card=i*ones(1,numel(segind)); % cardinality of segment
        r(end).card=ones(1,numel(segind))*i;
        
        r(end).seg=p(i).seg{j}; %set of segment
        allSegs{end+1}=p(i).seg{j};
        %r(end).seg=pitches(p(i).segind{j}(1):p(i).segind{j}(1)+i-1);
        r(end).segcount=numel(p(i).segind{j}); % number of insances
        if usetime==1
            r(end).cov=sum(nmat(segind+i-1,1)+nmat(segind+i-1,2)-nmat(segind,1));
        else
            r(end).cov=numel(segind)*i; % segment coverage (cardinality X instances)
        end
        %r(end).invind=[]; % not used but present to work with arcPlot
        %allcov(end+1)=r(end).cov; % segment coverage (cardinality X instances)
    end
end
r(1)=[]; % remove initialized placeholder
allSegs(1)=[];
%allcov(1)=[]; % remove initialized placeholder

[uSets, ~ ,idx2] = uniquecell(allSegs);
r2(1).seg=p(cmin).seg{1};
r2(1).card=cmin;
r2(1).segind=p(cmin).segind{1};
r2(1).segcount=numel(p(cmin).segind{1});
r2(1).cov=numel(p(cmin).segind{1})*cmin;
%r2(1).invind=[]; % not used but present to work with arcPlot
for i=1:numel(uSets)
    newSegInd=[];
    newCard=[];
    ind=find(idx2==i);
    for j=1:numel(ind)
        newSegInd=[newSegInd,r(ind(j)).segind];
        newCard=[newCard,r(ind(j)).card];
    end
    [newCard, sortInd]=sort(newCard,'descend');
    newSegInd=newSegInd(sortInd);
    [newSegInd,IA,IC]=unique(newSegInd);
    newCard=newCard(IA);
    onsets=nmat(newSegInd,1);
    [onsets,sortInd]=sort(onsets);
    newCard=newCard(sortInd);
    newSegInd=newSegInd(sortInd);
    r2(end+1).seg=uSets{i};
r2(end).card=newCard;
r2(end).segind=newSegInd;
r2(end).segcount=numel(newSegInd);
r2(end).cov=sum(newCard);
%r2(end).invind=[];
end
r2(1)=[];
r=r2;

%% sort by coverage
clear cov
for i=1:numel(r)
    cov(i)=r(i).cov;
end
[~, SortInd]=sort(cov,'descend'); % sort based on coverage
r=r(SortInd); % sort r based on all cov

%numel(r)


% add new features
for i=1:numel(r)
        onsets=nmat(r(i).segind,1);
    [~,sortInd]=sort(onsets);
    r(i).segind=r(i).segind(sortInd);
    %card=r(i).card;
    %r(i).card=card*ones(1,numel(r(i).segind)); % cardinality of segment
    for j=1:numel(r(i).segind)
        r(i).key(j)=nan;
        r(i).keytext{j}='';
    end
    r(i).nmatSR=nmat;
    %ßr(i).seg=CL(1,r(i).segind:r(i).segind+r(i).card(1)-1);
    r(i).type=4;
    r(i).name=['PCSet [' num2str(r(i).seg) ']'];
    r(i).keyaxi=r(i).key;
    r(i).keyDisp=1;
    r(i).axi=[];
        r(i).opacity=.3;
        r(i).arcType=1;
        r(i).show=1;
        r(i).arcDir=1;
end



end