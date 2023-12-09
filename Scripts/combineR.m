function r2=combineR(r,rselect)
if r(rselect(1)).type==r(rselect(2)).type
seg=r(rselect(1)).seg;
nmat=r(rselect(1)).nmatSR;
segcount=r(rselect(1)).segcount;
segind=r(rselect(1)).segind;
card=r(rselect(1)).card;
cov=r(rselect(1)).cov;
%inds=r(rselect(1)).inds;
for i=2:numel(rselect)
    segind=[segind,r(rselect(i)).segind];
    card=[card,r(rselect(i)).card];
    %inds=[inds,r(rselect(i)).inds];
end

r2(1).seg=seg;
[segind, IA, IC]=unique(segind);
card=card(IA);
segindonsets=nmat(segind,1);
[~, sortInd]=sort(segindonsets);
card=card(sortInd);
segind=segind(sortInd);
r2(1).segcount=numel(segind);
r2(1).segind=segind;
r2(1).cov=sum(card);
%r2(1).invind=[];
r2(1).card=card;
%r2(1).inds=inds;
r2.key=[];
for i=1:numel(segind)
    r2.key(i)=nan;
end
    r2(1).name=r(rselect(1)).name;
    r2(1).type=r(rselect(1)).type;
    r2(1).nmatSR=r(rselect(1)).nmatSR;
        r2.keyDisp=r(rselect(1)).keyDisp;
    r2.arcType=r(rselect(1)).arcType;
    r2.keyaxi=r2.key;
    r2.keyDisp=r(rselect(1)).keyDisp;
    r2.axi=[];
    r2.arcDir=1;
    r2.show=1;
    r2.opacity=.3;
end
end