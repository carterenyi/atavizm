 ps=[63,65,66,68,63,63,65,66,68]
% ps=ps+3;
mps=mod(ps,12);
[sps,ind]=sort(mps);
temp=sps;
for i=1:numel(sps)
    nf{i}=temp;
    nfrange(i)=nf{i}(end)-nf{i}(1);
    temp=temp([2:end,1]);
    temp(end)=temp(end)+12;
end
[~,nf_ind]=min(nfrange);
nf=nf{nf_ind};
t=nf(1);
t_loc=find(mps==t);
pf1=sort(unique(nf-t));
pf2=sort(abs(pf1-pf1(end)));
if sum(pf2) < sum(pf1)
    pf=pf2
else
    pf=pf1
end
%pf=sort(unique(rpf));