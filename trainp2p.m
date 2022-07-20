%% train detection based on peak-to-peak distance
function train=trainp2p(x,y,wind)
    train=[];
    for i=1:length(x)
        res=find(y>=x(i)+wind(1) & y<=x(i)+wind(2));
        for j=1:length(res)
            train(length(train)+1,:)=[x(i),y(res(j))];
        end
    end
end


