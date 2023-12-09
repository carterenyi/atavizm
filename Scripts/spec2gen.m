function out=spec2gen(in)

    sints=[0,1,2,3,4,5,6,7,8,9,10,11];
    gints=[1,2,2,3,3,4,4.5,5,6,6,7,7];
   for i=1:numel(in)
       ind=find(sints==in(i));
       out(i)=gints(ind);
   end
   