function ints=spec2genComplementary(ints)
sints=[0,1,2,3,4,5,6,7,8,9,10,11];
%gints=[1,2,2,3,3,4,4.5,5,6,6,7,7];
gints=[1,2,2,3,3,4,4.5,-4,-3,-3,-2,-2];
for i=1:numel(ints)
    if isnan(ints(i))==0
        if ints(i)<0
            sign=-1;
        else
            sign=1;
        end
        for k=1:numel(sints)
            if mod(abs(ints(i)),12)==sints(k)
                ints(i)=sign*gints(k);
                break
            end
        end
    end
end