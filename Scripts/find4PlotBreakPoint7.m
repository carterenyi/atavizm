function [r,nmat,durind]=find4PlotBreakPoint7(in)

%CAUTION:
%1. does not work with human playback settings
%(turn off in Finale or Sibelius)
input=in.input;
nmat=in.nmat;
sel=in.sel;
ED=in.ED;
gen=in.generic;
duryes=in.duryes

pitches=nmat(:,4);
pitches=pitches';

if in.redCLS==1
    if sel==4
        degrees=2;
    else
        degrees=1;
    end

    contcom=CT_makeContCom(pitches,degrees);
    inds=[];
    for i=numel(pitches):-1:2
        if contcom(:,i)==contcom(:,i-1)
            inds(end+1)=i;
        end
    end
    if isempty(inds)==0
        pitches(inds)=[];
        nmat(inds,:)=[];
    end
        contcom=CT_makeContCom(input,degrees);
    inds=[];
    for i=numel(input):-1:2
        if contcom(:,i)==contcom(:,i-1)
            inds(end+1)=i;
        end
    end
    if isempty(inds)==0
        input(inds)=[];
    end
end


if max(input)<20
    durs=nmat(:,1);
    durs=durs(2:end)-durs(1:end-1);
    durs(end+1)=nmat(end,2);
    durs=durs';
    durs=round(durs,2);
    pitches=durs;
end



% if nargin<3
%     sel=4;
% end

try
    durin=in.durin;
    durs=nmat(:,1);
    durs=durs(2:end)-durs(1:end-1);
    durs(end+1)=nmat(end,2);
    durs=durs';
    durs=round(durs,2);
    durin=round(durin,2);
    if in.lastdur==1
    durCAS=CT_makeContComCLSnansum(durin(1:end),1);
    else
        durCAS=CT_makeContComCLSnansum(durin(1:end-1),1);
    end
catch
end

inp{1}=input;
% inO=mod(inP,12);
%card{1}=numel(input);
inp{2}=inp{1}(2:end)-inp{1}(1:end-1);
%card{2}=numel(input);
inp{3}=makecomQ(inp{1});
%card{3}=numel(input);
inp{4}=CT_makeContComCLSnansum(inp{1},2);
%card{4}=numel(input);
inp{5}=CT_makeContComCLSnansum(inp{1},1);
%card{5}=numel(input);
for i=6:10
    inp{i}=inp{i-5};
    %card{i}=[];
end

clear ind card
for i=1:10
    ind{i}=[];
    card{i}=[];
    EDval{i}=[];
end
durind=[];

p=pitches;
incard=numel(input);
for i=1:numel(pitches)-incard+1
    if isnan(p(i))
        continue
    end
    if duryes==1
        testdurs=durs(i:i+incard-1);
        testdurs=round(testdurs,2);
        if in.lastdur==1
        durcomp=CT_makeContComCLSnansum(testdurs(1:end),1);
        else
                    durcomp=CT_makeContComCLSnansum(testdurs(1:end-1),1);
        end
        if durcomp==durCAS
            durind(end+1)=i;
        else
            continue
        end
    end
    testP=pitches(i:i+incard-1);
    out=PTCLS(input,testP,sel,gen);
    if out>0
        ind{out}(end+1)=i;
        card{out}(end+1)=numel(input);
    end
end

for i=2:5
    ind{i}=[ind{i},ind{i-1}];
    card{i}=[card{i},card{i-1}];
end

p=pitches;
c=incard;
in=input;

%edit distance

if ismember(sel,[1,2,5])==1
    %if nargin>3
    if isnan(ED)==0
        for i=1:numel(p)
            if isnan(p(i))
                continue
            end
            EDtest=[];
            Ctest=[];
            clear testP
            testP{1}=[];
            for j=-ED:ED
                if duryes==1
                    testdurs=durs(i:i+incard-1);
                    testdurs=round(testdurs,2);
                    durcomp=CT_makeContComCLSnansum(testdurs(1:end-1),1);
                    if durcomp==durCAS
                        durind(end+1)=i;
                    else
                        continue
                    end
                end
                if i+incard-1+j>numel(p)
                    continue
                end
                testP{end+1}=pitches(i:i+incard-1+j);
                intemp=input;
                if sel==1
                    %leave as is
                elseif sel==2
                    intemp=intemp(2:end)-intemp(1:end-1);
                    testP{end}=testP{end}(2:end)-testP{end}(1:end-1);
                elseif sel==3
                    continue
                elseif sel==4
                    intemp=CT_makeContComCLSnansum(intemp,2);
                    testP{end}=CT_makeContComCLSnansum(testP{end},2);
                    
                elseif sel==5
                    intemp=CT_makeContComCLSnansum(intemp,1);
                    testP{end}=CT_makeContComCLSnansum(testP{end},1);
                end
                EDtest(end+1)=lev(intemp,testP{end});
                %     out=PTCLS(input,testP,sel);
                %     if out>0
                %         ind{out}(end+1)=i;
                %         card{out}(end+1)=numel(input);
                %     end
            end
            testP(1)=[];
            [testmin, testind]=min(EDtest);
            thisED=ED;
            if sel>1
                thisED=thisED+1;
                if sel>3
                    thisED=thisED+1;
                end
            end
            if testmin<=thisED
                ind{6}(end+1)=i;
                card{6}(end+1)=numel(testP{testind(end)});
                EDval{6}(end+1)=testmin;
            end
        end
        %end
    end
else
    %if nargin>3
        if isnan(ED)==0
            %ED=ED;
            
            %break (e.g. octave displacement)
            for i=1:numel(p)-c+1
                tP=p(i:i+c-1);
                if nargin==5
                    tD=durs(i:i+c-1);
                    tD=round(tD,2);
                end
                for j=2:numel(in)
                    if in.duryes==1
                        D1=durin(1:j-1);
                        
                        tD1=tD(1:j-1);
                        
                        if CT_makeContComCLSnansum(D1,1)~=CT_makeContComCLSnansum(tD1,1)
                            continue
                        end
                        D2=durin(j:end);
                        tD2=tD(j:end);
                        if CT_makeContComCLSnansum(D2,1)~=CT_makeContComCLSnansum(tD2,1)
                            continue
                        end
                    end
                    P=in;
                    P1=P(1:j-1);
                    tP1=tP(1:j-1);
                    out1=PTCLS(P1,tP1,sel,gen);
                    if out1>0
                        P2=P(j:end);
                        tP2=tP(j:end);
                        out2=PTCLS(P2,tP2,sel,gen);
                        if out2>0
                            out=min([out1,out2]);
                            ind{out+5}(end+1)=i;
                            card{out+5}(end+1)=numel(tP);
                            break
                        end
                    end
                end
            end
        else
            ED=0;
        end
        
        
        %use nchoosek then tally edits, break when 3, if less then 3 add it,
        %exclude first index its redundant, e.g. 2:n not 1:n for nchoosek,
        %including breakpoint
        
        if ED>0
            %deletion
            for k=1:ED
                for i=1:numel(p)-c+1+k
                    tP=p(i:i+c-1-k);
                    if nargin==5
                        tD=durs(i:i+c-1-k);
                        tD=round(tD,2);
                    end
                    for j=1:numel(in)-k+1
                        if in.duryes==1
                            D1=durin(1:j-1);
                            tD1=tD(1:j-1);
                            if CT_makeContComCLSnansum(D1,1)~=CT_makeContComCLSnansum(tD1,1)
                                continue
                            end
                            D2=durin(j+k:end);
                            tD2=tD(j:end);
                            if CT_makeContComCLSnansum(D2,1)~=CT_makeContComCLSnansum(tD2,1)
                                continue
                            end
                        end
                        P1=in(1:j-1);
                        tP1=tP(1:j-1);
                        out1=PTCLS(P1,tP1,sel,gen);
                        if out1>0
                            P2=in(j+k:end);
                            tP2=tP(j:end);
                            out2=PTCLS(P2,tP2,sel,gen);
                            if out2>0
                                out=min([out1,out2]);
                                ind{out+5}(end+1)=i;
                                card{out+5}(end+1)=numel(tP)-k;
                                break
                            end
                        end
                        
                    end
                end
            end
            
            %substitution
            for k=1:ED
                for i=1:numel(p)-c+1
                    tP=p(i:i+c-1);
                    if nargin==5
                        tD=durs(i:i+c-1);
                        tD=round(tD,2);
                    end
                    for j=1:numel(in)-k+1
                        if in.duryes==1
                            D1=durin(1:j-1);
                            tD1=tD(1:j-1);
                            if CT_makeContComCLSnansum(D1,1)~=CT_makeContComCLSnansum(tD1,1)
                                continue
                            end
                            D2=durin(j+k:end);
                            tD2=tD(j+k:end);
                            if CT_makeContComCLSnansum(D2,1)~=CT_makeContComCLSnansum(tD2,1)
                                continue
                            end
                        end
                        P1=in(1:j-1);
                        tP1=tP(1:j-1);
                        out1=PTCLS(P1,tP1,sel,gen);
                        if out1>0
                            P2=in(j+k:end);
                            tP2=tP(j+k:end);
                            out2=PTCLS(P2,tP2,sel,gen);
                            if out2>0
                                out=min([out1,out2]);
                                ind{out+5}(end+1)=i;
                                card{out+5}(end+1)=numel(tP);
                                break
                            end
                        end
                        
                    end
                end
            end
            
            %insertion
            for k=1:ED
                for i=1:numel(p)-c+1-k
                    tP=p(i:i+c-1+k);
                    if nargin==5
                        tD=durs(i:i+c-1+k);
                        tD=round(tD,2);
                    end
                    for j=1:numel(in)-k+1
                        if in.duryes==1
                            D1=durin(1:j-1);
                            tD1=tD(1:j-1);
                            if CT_makeContComCLSnansum(D1,1)~=CT_makeContComCLSnansum(tD1,1)
                                continue
                            end
                            D2=durin(j:end);
                            tD2=tD(j+k:end);
                            if CT_makeContComCLSnansum(D2,1)~=CT_makeContComCLSnansum(tD2,1)
                                continue
                            end
                        end
                        P1=in(1:j-1);
                        tP1=tP(1:j-1);
                        out1=PTCLS(P1,tP1,sel,gen);
                        if out1>0
                            P2=in(j:end);
                            tP2=tP(j+k:end);
                            out2=PTCLS(P2,tP2,sel,gen);
                            if out2>0
                                out=min([out1,out2]);
                                ind{out+5}(end+1)=i;
                                card{out+5}(end+1)=numel(tP);
                                break
                            end
                        end
                    end
                end
            end
        end
    %end
end

for i=7:10
    ind{i}=[ind{i},ind{i-1}];
    card{i}=[card{i},card{i-1}];
    EDval{i}=[EDval{i},EDval{i-1}];
end

for i=6:10
    for j=numel(ind{i}):-1:1
        if card{i}(j) < 1
            card{i}(j)=[];
            ind{i}(j)=[];
        end
        
    end
    for j=numel(ind{i}):-1:1
        onset=nmat(ind{i}(j),1);
        offset=nmat(ind{i}(j)+card{i}(j)-1,1);
        if offset < onset
            ind{i}(j)=[];
            card{i}(j)=[];
        end
    end
end

for j=6:10
    [ind{j},IA,~]=unique(ind{j});
    card{j}=card{j}(IA);
    if sel==1
        EDval{j}=EDval{j}(IA);
    end
    for i=numel(ind{j})-1:-1:1
        continueit=0;
        if sel==1
            for k=1:EDval{j}(i)
                if ind{j}(i)==ind{j}(i+1)-k
                    if EDval{j}(i)>EDval{j}(i+1)
                        ind{j}(i)=[];
                        card{j}(i)=[];
                        EDval{j}(i)=[];
                        continueit=1;
                        break
                    else
                        ind{j}(i+1)=[];
                        card{j}(i+1)=[];
                        EDval{j}(i+1)=[];
                        continueit=1;
                        break
                    end
                end
            end
        else
            for k=1:ED
                if ind{j}(i)==ind{j}(i+1)-k
                    ind{j}(i+1)=[];
                    card{j}(i+1)=[];
                    continueit=1;
                    break
                end
            end
            if continueit==1 % is this needed??
                continue
            end
        end
    end
    
    inter=[];
    if isnan(ED)==0
        for i=-ED:ED
            %for k=5:j-1
            inter=[inter, intersect(ind{j},ind{j-5}+i)];
            %end
        end
    end
    
    for i=1:numel(inter)
        delind=find(ind{j}==inter(i));
        ind{j}(delind)=[];
        card{j}(delind)=[];
    end
end

for i=1:10
    r(i).seg=inp{i};
    if i==2 || i==7
        if gen==1
            r(i).seg=spec2genComplementary(r(i).seg);
        end
    end
    r(i).segcount=numel(ind{i});
    r(i).segind=ind{i};
    r(i).card=card{i};
    r(i).cov=sum(card{i});
    %r(i).invind=[];
    r(i).inds=[];
    if size(r(i).seg,1)>size(r(i).seg,2)
        r(i).seg=r(i).seg';
    end
    if mod(i-1,5)+1==1
        r(i).name=['P [' num2str(r(i).seg) ']'];
    elseif mod(i-1,5)+1==2
        if gen==1
        r(i).name=['GI [' num2str(r(i).seg) ']'];
        else
            r(i).name=['T [' num2str(r(i).seg) ']'];
        end
    elseif mod(i-1,5)+1==3
        r(i).name=['C [' num2str(sum(r(i).seg)) ']'];
    elseif mod(i-1,5)+1==4
        r(i).name=['L [' num2str(r(i).seg) ']'];
    elseif mod(i-1,5)+1==5
        r(i).name=['S [' num2str(r(i).seg) ']'];
    end
    r(i).type=1;
    r(i).nmatSR=nmat;
    %     for j=1:numel(ind{i})
    %         i=i;
    %         indtest=ind{i}(j);
    %         cardtest=card{i}(j);
    %         temp=ind{i}(j):ind{i}(j)+card{i}(j)-1;
    %         r(i).inds=[r(i).inds, temp];
    %     end
    for j=1:numel(r(i).segind)
        r(i).key(j)=nan;
        r(i).keytext{j}='';
        r(i).keyaxi(j)=nan;
    end
    r(i).keyDisp=1;
    r(i).axi=[];
    r(i).arcType=1;
    r(i).show=1;
    r(i).opacity=.3;
    r(i).arcDir=1;
end

end