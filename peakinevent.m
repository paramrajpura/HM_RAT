% finds cooccurences of events.
% A cooccurrence is defined as when the peak of the event x is taking place
% within the boundaries of the event y.
%
%Inputs:
% x : event whose peak is going to be evaluated
% y : event whose boundaries are evaluated
%
% In other words, the peak of an istance of x is occurring between the
% beginning and the end of an instance of y
%
%Output:
%The signle output "train" is a nX3 matrix; each row refers to a
%cooccurence, while the first row refers to the peak of x and the last 2
%are the beginning and end of y

function train=peakinevent(x,y)
    train=[];
    for i=1:size(x,1)
        b=find(y(:,1)<=x(i,2),1,'last'); % b is the event y closest to x(i) that starts before it
        if x(i,2)<=y(b,3)
            train(size(train,1)+1,:)=[x(i,2),y(b,[1,3])];
        end
    end
end

