% plotting function

%input:
%
% - x is the data matrix, in the form chanXtime
%
% - chan is a vector with the channels that you want to look at. 
%   an example would be:
%   chan=[12 15 17 22]


function plot1(x,chan,color)
    if ~exist('color','var')
      color = 'k';
    end
    cr=length(chan);
    zoom=20;
    win=20;
    center=win/2;
    fs=600;
    for i=1:cr
    ax(i)=subplot(cr, 1, i);
        plot([1:length(x(chan(i),:))]/fs,x(chan(i),:)-mean(x(chan(i),:)),color)
    hold on
    %plot([0 length(x)], [mean(x(chan(i),:)) mean(x(chan(i),:))],'color',[0.9 0.9 0.9])
    axis([center-win/2 center+win/2 -std(x(chan(i),:))*zoom std(x(chan(i),:))*zoom])
    linkaxes(ax,'x');
    xlabel("Time (seconds)")
    end
    
end