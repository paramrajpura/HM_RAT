function train=peakinevent(x,y)
    train=[];
    for i=1:size(x,1)
        b=find(y(:,1)<=x(i,2),1,'last');
        if x(i,2)<=y(b,3)
            train(size(train,1)+1,:)=[x(i,2),y(b,[1,3])];
        end
    end
end


