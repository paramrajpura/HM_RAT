% train detection based on peak-to-peak distance

%Input
%
% x : first event of the train
% y : second event of the train
% wind : horizontal vector of length to ( e.g. [100 1300]
function train=trainp2p(x,y,wind)
    train=[];
    clear res
    for i=1:length(x)
        res=find(y>=x(i)+wind(1) & y<=x(i)+wind(2));
        if res
            for j=1:length(res)
                train(size(train,1)+1,:)=[x(i),y(res(j))];
            end
        end
    end
end

