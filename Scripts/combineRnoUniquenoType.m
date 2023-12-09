function r2=combineRnoUniquenoType(r,rselect)

%if r(rselect(1)).type==r(rselect(2)).type
    seg=r(rselect(1)).seg;
    nmat=r(rselect(1)).nmatSR;
    %segcount=r(rselect(1)).segcount;
    segind=r(rselect(1)).segind;
    card=r(rselect(1)).card;
    key=r(rselect(1)).key;
    keytext=r(rselect(1)).keytext;
    %cov=r(rselect(1)).cov;
    %inds=r(rselect(1)).inds;
    try
        seg=r(rselect(1)).seg;
    catch
    end
    indexadd=0;
    for i=2:numel(rselect)
        if numel(nmat(:,1))==numel(r(rselect(i)).nmatSR(:,1))
            if nmat(:,1)~=r(rselect(i)).nmatSR(:,1)
                indexadd=numel(nmat(:,1));
                nmat=[nmat;r(rselect(i)).nmatSR];
            end
        elseif numel(nmat(:,1))~=numel(r(rselect(i)).nmatSR(:,1))
            indexadd=numel(nmat(:,1));
            nmat=[nmat;r(rselect(i)).nmatSR];
        end
        segind=[segind,(r(rselect(i)).segind+indexadd)];
        card=[card,r(rselect(i)).card];
        key=[key,r(rselect(i)).key];
        keytext=[keytext,r(rselect(i)).keytext];
        %inds=[inds,r(rselect(i)).inds];
    end
    
    %i=1;
    r2.seg=seg;
    %segind=unique(segind);
   % try
        r2.seg=seg;
   % catch
   % end
    r2.segcount=numel(segind);
    r2.segind=segind;
    r2.cov=sum(card);
    %r2(i).invind=[];
    r2.card=card;
    %r2.inds=inds;
    r2.nmatSR=nmat;
    r2.name=r(rselect(1)).name;
    r2.type=r(rselect(1)).type;
    %r2.nmatSR=r(rselect(1)).nmatSR;
    r2.arcDir=r(rselect(1)).arcDir;
    r2.key=key;
    r2.keytext=keytext;
    r2.keyDisp=r(rselect(1)).keyDisp;
    r2.arcType=r(rselect(1)).arcType;
    r2.keyaxi=key;
    r2.keyDisp=r(rselect(1)).keyDisp;
    r2.axi=[];
    r2.arcDir=1;
    r2.show=1;
    r2.opacity=.3;
%end
end