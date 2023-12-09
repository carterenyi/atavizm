function nmat=restasnan(nmat)
    for i=numel(nmat(:,1)):-1:2
        onset=nmat(i,1);
        offset=nmat(i-1,1)+nmat(i-1,2);
        diff=onset-offset;
        if diff>=.25
            newline=nmat(i,:);
            newline(4)=nan;
            newline(1)=offset;
            newline(2)=diff;
            newnmat=[nmat(1:i-1,:);newline;nmat(i:end,:)];
            nmat=newnmat;
        end
    end
end