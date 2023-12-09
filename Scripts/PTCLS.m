function out=PTCLS(p1,p2,sel,gen)

out=0;
if nargin < 3
    s1=CT_makeContComCLSnansum(p1,1);
    s2=CT_makeContComCLSnansum(p2,1);
    if s1==s2
        out=5;
        l1=CT_makeContComCLSnansum(p1,2);
        l2=CT_makeContComCLSnansum(p2,2);
        if l1==l2
            out=4;
            c1=makecomQ(p1);
            c2=makecomQ(p2);
            if c1==c2
                out=3;
                t1=p1(2:end)-p1(1:end-1);
                t2=p2(2:end)-p2(1:end-1);
                if t1==t2
                    out=2;
                    if p1==p2
                        out=1;
                    end
                end
            end
        end
    end
elseif sel==1
    if p1==p2
        out=1;
    else
        out=0;
    end
elseif sel==2
    
    t1=p1(2:end)-p1(1:end-1);
    t2=p2(2:end)-p2(1:end-1);
    if gen==1
        t1=spec2genComplementary(t1);
        t2=spec2genComplementary(t2);
    end
    if t1==t2
        out=2;
    else
        out=0;
    end
elseif sel==3
    c1=makecomQ(p1);
    c2=makecomQ(p2);
    if c1==c2
        out=3;
    else
        out=0;
    end
elseif sel==4
    l1=CT_makeContComCLSnansum(p1,2);
    l2=CT_makeContComCLSnansum(p2,2);
    if l1==l2
        out=4;
    else
        out=0;
    end
elseif sel==5
    s1=CT_makeContComCLSnansum(p1,1);
    s2=CT_makeContComCLSnansum(p2,1);
    if s1==s2
        out=5;
    else
        out=0;
    end
end
end