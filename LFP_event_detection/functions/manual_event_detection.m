function eve_m = manual_event_detection(signal,signal_bp,hpc,fs)
    close all
    clearvars x y
    figure(1)
    sgtitle('Manual ripple detector')
    distance=4;
    zoom=0.6;
    center=3;
    plot([0:length(signal(hpc,:))-1]/fs,3*zscore(signal(hpc,:)))
    hold on
    plot([0:length(signal(hpc,:))-1]/fs,1.6*zscore(signal_bp(hpc,:))+distance)
    xlabel("Seconds")
    axis([center-3 center+3 -std(7*zscore(signal(hpc,:)))*zoom std(7*zscore(signal(hpc,:)))*zoom+distance])
     button = 1;
    % while sum(button) <=3   % read ginputs until a mouse right-button occurs
    % 	[x,y,button] = ginput(3);
    % end
    eve_m=[];
    trh=0;
    while sum(button) <=4   % read ginputs until a mouse right-button occurs
        button=1;
        while sum(button) <=1   % read ginputs until a mouse right-button occurs
            try
                [x,y,button] = ginput(1);
            catch
                return
            end
            if x(end)>=center+2.5
                center=center+2;
                x=x(1:end-1);
                y=y(1:end-1);
                button=3;
            elseif x(end)<=center-2.5 && center>=5
                center=center-2;
                button=3;
                x=x(1:end-1);
                y=y(1:end-1);
            elseif ~isempty(x)
                eve_m=[eve_m,x(end)]
                plot(x(end),y(end),"*","color","red")
            end
        end
        axis([center-3 center+3 -std(7*zscore(signal(hpc,:)))*zoom std(7*zscore(signal(hpc,:)))*zoom+distance])
    end
    
%     
%     
% 
%   x=manual(7);  
% signal=data;
% signal_bp=data_bp;
% hpc=14;
% fs=600;
% 
% 
% signal_bp(round(x))
% 
% find(signal_bp(round(x)))














