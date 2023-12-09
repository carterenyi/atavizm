function pitch=xmlpitch(notedat)
letters={'C','D','E','F','G','A','B'};
sts=[0,2,4,5,7,9,11];
st=nan;
for i=1:numel(letters)
if strcmp(notedat.pitch,letters{i})==1
    st=sts(i);
    pitch=st+12*(notedat.octave+1);
    break
end
pitch=st;
end

if isnan(notedat.alter)==0
        if strcmp(notedat.accidental,'quarter-sharp')
            pitch=pitch+.5;
        elseif strcmp(notedat.accidental,'quarter-flat')
            pitch=pitch-.5;
        else
            pitch=pitch+notedat.alter;
        end
end


