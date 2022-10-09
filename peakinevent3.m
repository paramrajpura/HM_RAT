% finds cooccurences of 3 events
% A cooccurrence is defined as when the peak of the event x and event y is taking place
% within the boundaries of the event z
%
%Inputs:
% x : event whose peak is going to be evaluated
% train : output of function "peakinevent"
%
%
%Output:
%The signle output "train" is a nX4 matrix; each row refers to a
%cooccurence, while the first row refers to the peak of x, the second to
%the peak of y and the last two are the beginning and end of z

function train3=peakinevent3(x,train)
    train3=[];
    for i=1:length(train)
        try
            b=find(x(:,2)>=train(i,2),1,'first'); %b is the first event after the beginning of  the train
        catch continue
        end
        if x(b,2)<=train(i,3)
            train3(size(train3,1)+1,:)=[x(b,2), train(i,:)];
        end
    end
end