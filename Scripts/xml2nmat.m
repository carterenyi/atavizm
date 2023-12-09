function nmat=xml2nmat(filename)
% clear
% filename='190828 guitar.xml';

% filename='Omoluabi.musicxml';
xmldat = fileread(filename);

%% metadata
%title
try
    tagon='<movement-title>';
    tagoff='</movement-title>';
    a=strfind(xmldat,tagon);
    b=strfind(xmldat,tagoff);
    title=temp(a+numel(tagon):b-1);
catch
    title='';
end

%<identification>
%composer
try
    tagon='<creator type="composer">';
    tagoff='</creator>';
    a=strfind(xmldat,tagon);
    b=strfind(xmldat,tagoff);
    composer=temp(a+numel(tagon):b-1);
catch
    composer='';
end

%rights
try
    tagon='<rights>';
    tagoff='</rights>';
    a=strfind(xmldat,tagon);
    b=strfind(xmldat,tagoff);
    rights=temp(a+numel(tagon):b-1);
catch
    rights='';
end

%% part list
tagon='<part-list>';
tagoff='</part-list>';
a=strfind(xmldat,tagon);
b=strfind(xmldat,tagoff);
partlist=xmldat(a:b);
tagon='<score-part id="P';
tagoff='">';
tagoff2='</part-name>';
a=strfind(partlist,tagon);
c=strfind(partlist,tagoff2);
for i=1:numel(a)
    tempdat=partlist(a(i)+numel(tagon):c(i)-1);
    tempb=strfind(tempdat,tagoff);
    b(i)=tempb(1);
    partid(i)=str2double(tempdat(1:b(i)-1));
    partname{i}=partlist(b(i)+numel(tagoff):c(i)-1);
    partindex(i)=strfind(xmldat,['<part id="P' num2str(partid(i)) '">']);
end
for i=1:numel(partid)-1
    partdata{i}=xmldat(partindex(i):partindex(i+1));
end
partdata{end+1}=xmldat(partindex(end):end);

%% initialize nmat
nmat=zeros(1,7);
%% measure data
for k=1:numel(partdata)
    clear measure
    tagon='<measure number=';
    tagoff='</measure>';
    a=strfind(partdata{k},tagon);
    b=strfind(partdata{k},tagoff);
    measures{numel(a)}='';
    for i=1:numel(a)
        measures{i}=partdata{k}(a(i)+numel(tagon):b(i)-1);
        quotes=strfind(measures{i},'"');
        measnum(i)=str2num(measures{i}(quotes(1)+1:quotes(2)-1));
        tagon='<voice>';
        tagoff='</voice>';
        c=strfind(measures{i},tagon);
        d=strfind(measures{i},tagoff);
        vn(i)=str2num(measures{i}(c+numel(tagon):d-1));
    end
    
    
    for j=1:numel(measures)
        %measdat=measures{j};
        %divisions (beat value)
        tagon='<divisions>';
        tagoff='</divisions>';
        a=strfind(measures{j},tagon);
        b=strfind(measures{j},tagoff);
        if numel(a)>0
            divisions(j)=str2double(measures{j}(a+numel(tagon):b-1));
        else
            divisions(j)=divisions(j-1);
        end
        tagon='<beats>';
        tagoff='</beats>';
        a=strfind(measures{j},tagon);
        b=strfind(measures{j},tagoff);
        if numel(a)>0
            beats(j)=str2double(measures{j}(a+numel(tagon):b-1));
        else
            beats(j)=beats(j-1);
        end
        tagon='<beat-type>';
        tagoff='</beat-type>';
        a=strfind(measures{j},tagon);
        b=strfind(measures{j},tagoff);
        if numel(a)>0
            beattype(j)=str2double(measures{j}(a+numel(tagon):b-1));
        else
            beattype(j)=beattype(j-1);
        end
        
        
        %key
        tagon='<key>';
        tagoff='</key>';
        a=strfind(measures{j},tagon);
        b=strfind(measures{j},tagoff);
        if numel(a)>0
            key{j}{numel(a)}='';
            tonic{j}{numel(a)}='';
            mode{j}{numel(a)}='';
            for i=1:numel(a)
                key{j}{i}=measures{j}(a(i)+numel(tagon):b(i)-1);
                tagon='<fifths>'; % what does -3 mean, is it Eb?
                tagoff='</fifths>';
                a2=strfind(key{j}{i},tagon);
                b2=strfind(key{j}{i},tagoff);
                tonic{j}{i}=key{j}{i}(a2+numel(tagon):b2-1);
                tagon='<mode>';
                tagoff='</mode>';
                a2=strfind(key{j}{i},tagon);
                b2=strfind(key{j}{i},tagoff);
                mode{j}{i}=key{j}{i}(a2+numel(tagon):b2-1);
            end
        else
            key{j}{1}='';
        end
        
        %  <attributes>
        %         <divisions>48</divisions>
        %         <key>
        %           <fifths>0</fifths>
        %           <mode>major</mode>
        %         </key>
        %         <time>
        %           <beats>6</beats>
        %           <beat-type>8</beat-type>
        %         </time>
        %         <clef>
        %           <sign>G</sign>
        %           <line>2</line>
        %           <clef-octave-change>-1</clef-octave-change>
        %         </clef>
        %         <transpose>
        %           <diatonic>0</diatonic>
        %           <chromatic>0</chromatic>
        %           <octave-change>-1</octave-change>
        %         </transpose>
        %       </attributes>
        %       <sound tempo="120"/>
        %       <direction placement="above">
        %         <direction-type>
        %           <metronome default-y="33" font-family="EngraverTextT" font-size="7.1" halign="left">
        %             <beat-unit>quarter</beat-unit>
        %             <beat-unit-dot/>
        %             <per-minute>80</per-minute>
        %           </metronome>
        %         </direction-type>
        %       </direction>
        
        
        
        %% low-level data
        tagon='<note';
        a=strfind(measures{j},tagon);
        if numel(a)>0
            clear note
            b=strfind(measures{j},'</note');
            note{numel(a)}='';
            for i=1:numel(a)
                note{i}=measures{j}(a(i)+numel(tagon):b(i)-1);
                c=strfind(note{i},'</step>');
                d=strfind(note{i},'</octave>');
                tagon='<accidental>';
                tagoff='</accidental>';
                e=strfind(note{i},tagon);
                f=strfind(note{i},tagoff);
                %if numel(c)>0
                v(k).m(measnum(j)).note(i).pitch=note{i}(c-1);
                v(k).m(measnum(j)).note(i).octave=str2double(note{i}(d-1));
                v(k).m(measnum(j)).note(i).accidental=note{i}(e+numel(tagon):f-1);
                %end
                tagon='<alter>';
                tagoff='</alter>';
                e=strfind(note{i},tagon);
                f=strfind(note{i},tagoff);
                %if numel(c)>0
                v(k).m(measnum(j)).note(i).alter=str2double(note{i}(e+numel(tagon):f-1));
                %end
                tagon='<duration>';
                tagoff='</duration>';
                e=strfind(note{i},tagon);
                f=strfind(note{i},tagoff);
                %if numel(c)>0
                v(k).m(measnum(j)).note(i).duration=str2double(note{i}(e+numel(tagon):f-1));
                %end
                tagon='<type>';
                tagoff='</type>';
                e=strfind(note{i},tagon);
                f=strfind(note{i},tagoff);
                %if numel(c)>0
                v(k).m(measnum(j)).note(i).type=note{i}(e+numel(tagon):f-1);
                %end
                
                e=strfind(note{i},'<tied type="start" />');
                f=strfind(note{i},'<tied type="stop" />');
                if numel(e)>0
                    v(k).m(measnum(j)).note(i).tie=1;
                elseif numel(f)>0
                    v(k).m(measnum(j)).note(i).tie=0;
                else
                    v(k).m(measnum(j)).note(i).tie=nan;
                end
            end
        else
            v(k).m(measnum(j)).note(i)=[];
        end
        
        
    end
    onset=0;
    for i=1:numel(v(k).m)
        nextmeasonset=onset+(beats(i)/beattype(i))*4;
%         if isnan(nextmeasonset)==1
%             break
%         elseif isnan(onset)==1
%             break
%         end
        for j=1:numel(v(k).m(i).note)
            if isnan(v(k).m(i).note(j).duration)==1
                continue
            end
            nmat(end+1,:)=zeros(1,7);
            nmat(end,1)=onset;
            nmat(end,2)=v(k).m(i).note(j).duration/divisions(i);
            nmat(end,3)=k;
            nmat(end,4)=xmlpitch(v(k).m(i).note(j));
            nmat(end,5)=64;
            nmat(end,6)=nmat(end,1);
            nmat(end,7)=nmat(end,2);
            onset=onset+nmat(end,2);
            if onset>=nextmeasonset
                break
            end
        end
        onset=nextmeasonset;
    end
    
end
nmat(1,:)=[];
for i=numel(nmat(:,1)):-1:1
    if isnan(nmat(i,4))==1
        nmat(i,:)=[];
    end
end