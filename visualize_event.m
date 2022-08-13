%% script for visualizing the detections

%tabula rasa
clear all
close all
clc

%load the file of interest.

cd C:\Users\Emanuele\Desktop\uni\event

%[file,~] = uigetfile('*.m');
file='Rat_Hm_Ephys_Rat4_389239_20201111_postsleep.mat';
load(file)
rec=data.original;
rip=normalize(rec(2,:))/5;
rip_bp=normalize(data.bandpass(2,:))/10;
pfc=normalize(rec(1,:))/7;
pfc_bp=normalize(data.bandpass(5,:))/3.7; %change it to (5,:) if you're interested in delta
evo=data.ripple; %event of interest. Change to what you prefer
%parameters
fs=600;
win=1; %seconds
center=evo(1,2); %seconds
rip_y=1.3;
ripb_y=3.2;
pfc_y=0;
pfcb_y=2.4;
timestamp=[0:length(rip)-1]/fs;
hold on

plot(timestamp,(rip+rip_y),'Color',[0 51 102]/256)
plot(timestamp,(rip_bp+ripb_y),'Color',[0 51 102]/256)
plot(timestamp,(pfc+pfc_y),'Color',[0 0 0])
plot(timestamp,(pfc_bp+pfcb_y),'Color',[0 0 0])
set(gca,'Color',[240 240 240]/256)
xlabel('Seconds')
set(gca,'YTickLabel',[]);
axis([-win win -1.5 4])
for i=1:size(evo,1)
    %plot(evo(i,2),rip(find(timestamp==evo(1,2)))+rip_y,'o','Color',[255, 36, 0]/256)
    plot(evo(i,2),rip(find(timestamp==evo(i,2)))+rip_y,'*','Color',[255, 36, 0]/256,'MarkerSize',10)
    plot(evo(i,1),0,'|','Color',[128,128,128]/256,'MarkerSize',1000)
    plot(evo(i,3),0,'|','Color',[128,128,128]/256,'MarkerSize',1000)
end

xt = [-0.8];
yt = [3];
str = {'Welcome'};
text(xt,yt,str,'Color',[0 102 102]/256,'FontSize',20)

xt = [-0.8];
yt = [1.6];
str = {'Press right arrow key for next event'};
text(xt,yt,str,'Color',[0 102 102]/256,'FontSize',16)

xt = [-0.8];
yt = [1];
str = {'Press left arrow key for previous event'};
text(xt,yt,str,'Color',[0 102 102]/256,'FontSize',16)
%  while button==1 %until a right-click occurs
%      sgtitle(strcat('Event nr.',num2str(i),';  Total:',num2str(size(evo,1))))
%     [x,y,button] = ginput(2);
%     axis([evo(i,2)-win evo(i,2)+win -1.5 4])
%     prev=0;
%     if x>=prev
%         prev=evo(i,2);
%         i=i+1;
%     else
%         prev=event_peak(i);
%         i=i-1;
%     end
%     pause(0.1)
% end
i=0;
prev=0;
 while true %until a right-click occurs
     sgtitle(strcat('Event nr.',num2str(i),';  Total:',num2str(size(evo,1))))
    [x,y,button] = ginput(1);
    if button==29
        try
         prev=evo(i,2);
        catch
            prev=evo(1,2);
        end
        i=i+1;
    else
        try
         prev=evo(i,2);
        catch
            prev=evo(1,2);
        end
        i=i-1;
    end
    axis([evo(i,2)-win evo(i,2)+win -1.5 4])
    pause(0.1)
end

    
    
    
    
    
    
    
    
    
    
    