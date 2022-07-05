%% Event detection
% 
% The script will detect ripples, spindles and deltas
% 
% Emanuele Ciardo
% 
% Genzel Lab
% 
% December - May 2022

%% Set up the stage, ask the user what they want to process and load the files
clear all
close all

addpath('/home/genzel/Desktop//Emanuele/artifact_detector')
addpath('/home/genzel/Desktop/Emanuele/artifact_detector/fieldtrip')
addpath('/home/genzel/Desktop/Emanuele')
addpath('/home/genzel/Desktop/Emanuele/Event')  
addpath('/home/genzel/Desktop/Emanuele/Event/FMA/FMAToolbox')

addpath('/home/genzel/Desktop/Emanuele/Event/FMA/FMAToolbox/Analyses')
addpath('/home/genzel/Desktop/Emanuele/Event/FMA/FMAToolbox/General')
addpath('/home/genzel/Desktop/Emanuele/Event/FMA/FMAToolbox/Helpers')


fs=600; %sampling frequency
cd /home/genzel/Desktop/Emanuele/processed_data/ICA % folder where the downsampled files are stored
file = uigetfile("title","Select the processed file you want to analyse"); %ask the user to select the recording to load
load(file) %it will load the structure 'data'

decide=true; %set to true if you want to change thresholds for the artefact detection

%ask the user: original or ICA-cleaned?
prompt = {'Original or ICA-cleaned? 1 = original ; 2 = ICA-cleaned'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'2'};
dt = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
if dt==1
    file_tp='original';
elseif dt==2
    file_tp='ICA_cl';
end
name=data.name;

pfc=1;
hpc=2;
if dt==1
    dat=data.original;
elseif dt==2
    dat=data.cleaned;
end

%load the sleepscoring file
load('/home/genzel/Desktop/Emanuele/processed_data/sleepscore.mat')
%the loaded matrix 'sleepscore' is nXtime, where n is the number of study day and time the timeframes.
%I opted for this storing approach to simplify the opening of the files.  
a=dir;
clear c
for i=3:length(a)
    b=a(i).name;
    c(i,:)=b(1:33);
end
c=char(c);
%find which row of the sleepscoring matrix corresponds to the one for the
%current study day
for i=1:size(c,1)
    if findstr(c(i,:),data.name(1:33))
        res=i;
    end
end
states=sleepscore(res-2,:); 

%ask the user the event they want to investigate
prompt = {'Which event are you interested in? 1 = ripple; 2 = spindle; 3 = delta'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1'};
channel_oi = inputdlg(prompt,dlgtitle,dims,definput);
evo=str2num(channel_oi{1});
if evo==1
    ev_tp='ripple';
elseif evo==2
    ev_tp='spindle';
elseif evo==3
    ev_tp='delta';
end

%% bandpass
%the resulting variable data_bp (data_bandpassed) is a 6*time matrix, where
%the first 2 rows correspond to pfc and hpc ripple-band signal, the second
%2 spindle-band and the last 2 delta-band
for i=1:3
    data_bp([(i-1)*2+1:i*2],:)=bandpass_custom(dat,fs,i);
end
%The function bandpass_custom relies on a butterworth filter
%% Set the threshold for the artefact detection

tr=10; %default. Change the gate to true to choose better the threshold
trr=tr*mean(abs([dat(1,:),dat(2,:)]));
gate=decide; %if decide is set to false, the user will not be able to change later the threshold
if gate
    close all
    %the while loop allows the user to decide which threshold is best. It
    %will plot the signal together with the threshold, and subsequently ask
    %if the threshold has to be modified
    ttt=figure(1);
    while ishandle(ttt)
        subplot(2,1,1)
        hold off
        subplot(2,1,2)
        hold off
        plot1(dat,[1:2]) 

        trr=tr*mean(abs([dat(1,:),dat(2,:)]));
        subplot(2,1,1)
        a=plot([0,1000],[trr,trr]);
        subplot(2,1,2)
        b=plot([0,1000],[trr,trr]);
        prompt = {'Select the threshold'};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {num2str(tr),'hsv'};
        try
            res = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
        catch
            break
        end
        if res==tr
            break
        else
            tr=res;
        end
        pause(0.1)
    end
end
%% select the portion of the signal to substitute
%After having detected the timepoints in which the signal surpasses the
%threhsold, it is necessary to create a window before and after those
%timepoints (that because of the oscillatory nature of the artefacts)

det_t=sum(abs([dat(1,:);dat(2,:)])>=trr); %logic-like vector: a non-zero integer signifies that
%HPC or PFC surpassed the threshol in that timepoint
det_tt=det_t;
win=0.3*fs; %window that cuts out around the discontinuity
%in the 2 following for loops the timeframes in which the threshold is
%surpassed are treated as seeds from which the window expands before (first
%loop) and after (second loop). It works by summing the variable det_tt to
%the same variable but translated of a variable amount.
for j=1:win
    det_tt=det_tt+[det_t(j:end) zeros(1,j-1)];
end

for j=1:win
    det_tt=det_tt+[zeros(1,j-1) det_t(1:end-j+1) ];
end
det_tt=det_tt>=1; %now the variable is a logical

%% detect discontinuities. 
%the approach is the same of the previous threshold-based artefact
%detection, but 1) it will now consider the first derivative, instead of
%the simple signal and 2) it will have a different window, since often
%times the signal before the discontinuity if fine
tr=25; % 13 was working most times
tr_d=tr*mean(mean([abs(diff(dat(1,:)));abs(diff(dat(2,:)))]));
gate=decide;
if gate
    close all
    ttt=figure(1);
    sgtitle('Discontinuities detection')

    while ishandle(ttt)

        subplot(2,1,1)
        hold off
        subplot(2,1,2)
        hold off
        plot1([abs(diff(dat(1,:)));abs(diff(dat(2,:)))],[1:2]) 
        tr_d=tr*mean(mean([abs(diff(dat(1,:)));abs(diff(dat(2,:)))]));
        subplot(2,1,1)
        a=plot([0,1000],[tr_d,tr_d]);
        subplot(2,1,2)
        b=plot([0,1000],[tr_d,tr_d]);
        prompt = {'Select the threshold'};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {num2str(tr),'hsv'};
        try
            res = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
        catch
            break
        end
        if res==tr
            break
        else
            tr=res;
        end
        
        pause(0.1)
        
    end
end

%% same procedure of the one for the threshold-based artefact detector, but for the discontinuities

det_t=sum([abs(diff(dat(1,:)));abs(diff(dat(2,:)))]>=tr_d);

det_td=det_t;
win=0.05*fs; %window that cuts out before the discontinuity
for j=1:win
    det_td=det_td+[det_t(j:end) zeros(1,j-1)];
end
win=0.05*fs; %window that cuts out after the discontinuity
for j=1:win
    det_td=det_td+[zeros(1,j-1) det_t(1:end-j+1) ];
end
det_td=det_td>=1;
sum(det_td(6.5*600:7.5*600))
%% substitute the artifacts with the average
if ~exist('det_td')
    det_td=zeros(size(det_tt)-1);
end
det_ttd=or(det_tt,[det_td,0]);
data_ar=data_bp;
for i=1:6
    data_ar(i,det_ttd)=mean(data_ar(i,:));
end
close all
show=false; %false=don't show 1=ripple, 2=spindle, 3=delta
if show
    types={[1,2],[3,4],[5,6]};
    plot1(data_ar,cell2mat(types(show)))
    if show==1
        sgtitle('ripple-band')
    elseif show==2
        sgtitle('spindle-band')
    elseif show==3
        sgtitle('delta-band')    
    end
    subplot(2,1,1)
    title('pfc')
    subplot(2,1,2)
    title('hpc')
end
%% divide the recording into bouts of NREM sleep
% this will be useful for event detection: it allows to avoid
% discontinuities in the signal

state=states; %initialize 'state' equal to the sleepscoring vector 
% [reminder: the states vector is 1Hz, and each timepoint is an integer. 
% 1=wake; 2=artefact; 3=NREM; 4=intermediate; 5=REM]
clear bout
j=1;
 
while true
    try
        state=state(find(state==3,1):end); %trim 'state' until the first NREM timeframe
        bout(j)=find(state~=3,1)-1; %the bout is then from 1 to the first non-NREM timeframe -1
    catch
        break %the try-catch allows to stop the while loop when it's done
    end
    state=state(bout(j)+1:end); %'state' is now trimmed to exclude the bout just detected
    j=j+1;
end
bout=[1,[cumsum(bout)]*600]; %cumulative of bout to make it match with the signal
%% Detect the events

threshs=[4,2.5,2]; %standard thresholds for ripple, spindle and delta (for Fusaro function at least)
thresh=threshs(evo);
clear event
while true
    j=1;
    timestamp=[bout(1)+1:bout(end)+1]/fs;
    data_ar=[data_ar,zeros(6,bout(end)-size(dat,2))]; %it is necessary to zero-pad the signal to make it match with the length of the bouts
    
    %ripple detection is done
    if evo==1 %if ripple.
        %ripple detection is done per bout, but the threshold is determined
        %on the whole signal and is therefore the same for all bouts
        thr=std(data_ar(hpc,:))*thresh; %the threshold is a function of the std of the signal
        event=[];
        for j=1:length(bout)-1
            [event_st,event_peak,event_end]=findRipplesLisa(data_ar(hpc,bout(j):bout(j+1)),timestamp(bout(j):bout(j+1)),thr,thr/2,fs);
            event=[event';[event_st;event_end;event_peak]']'; %store the detected events by appending the 'event' variable to itself
        end
    end
    event=event';
    if evo==2 %if spindle
        target=data_ar(2+pfc,:);
        timestamp=[1:length(target)]/fs;
        event=FindSpindles([timestamp;target]',thresh);
    elseif evo==3 %if delta
        target=data_ar(4+pfc,:);
        timestamp=[1:length(target)]/fs;
        event=FindDeltaWaves([timestamp;target]',thresh);
    end
  
%     for j=2:length(bout)-1
%             timestamp=[bout(j)+1:bout(j+1)]/fs;
%             if evo==1
%                 target=data_ar(hpc,bout(j)+1:bout(j+1));
%                 event = [event;FindRipples([timestamp;target]',thresh)];
%                 target=data_ar(hpc,:);
%             end                 
%     end
    if evo==1
            target=data_ar(hpc,:);
	elseif evo==2
                target=data_ar(2+pfc,:);
	elseif evo==3
                target=data_ar(4+pfc,:);
	end
    
    event_start=event(:,1);
    event_peak=event(:,2);
    event_end=event(:,3); 
    


% plot start, peak and end of the event
    close all
    ttt=figure(1);
    sgtitle(strcat("Detected events. Total:",num2str(length(event_peak))))
    distance=5;
    z=1*zscore(dat(hpc,:));
    zz=0.5*abs(zscore(target))+distance;
    if evo==3
        zz=0.5*zscore(target)+distance;
    end
    plot([0:length(dat(hpc,:))-1]/fs,z,"k","LineWidth",0.000000001)
    set(gca,'Color',[238,232,170]/256)
    hold on
    plot([0:length(data_ar(hpc,:))-1]/fs,zz,"LineWidth",2,"color",[0,128,128]/256)
    plot([event_peak(1)],z(timestamp==event_peak(1)),"o","color","red",'MarkerSize',12)
    legend('recording','bandpass','event','AutoUpdate','off')
    xlabel("Seconds")
    show_peak=1;
    numme=1000;
    if size(event_end,1)<=numme
        numme=size(event_end,1);
    end
    for i=1:numme
    plot([event_start(i)],z(timestamp==event_peak(i)),"|","color","magenta")
    end
    for i=1:numme
        if abs(z(timestamp==event_peak(i)))<10
            plot([event_peak(i)],z(timestamp==event_peak(i)),"o","color","red",'MarkerSize',12)
        else
            plot([event_peak(i)],0,"o","color","red")
        end
    end
    for i=1:numme
    plot([event_end(i)],z(timestamp==event_peak(i)),"|","color","magenta")
    end
    i=0;
    while ishandle(ttt) & i<=length(event_peak)-1
        i=1+i;
        axis([event_peak(i)-3 event_peak(i)+3 -10 20])
        pause(1.5)
    end
    prompt = {'Do you want to change the threshold? ~ 0 = no ~ other number = new threshold'};
    dlgtitle = 'Input';
    dims = [1 50];
    definput = {num2str(thresh),'hsv'};
    res=str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
    if res==0 || res==thresh
        break
    else
        thresh=res;
    end
        
end


%% another visualization method
%double left-click on the right part of the plot moves the plot to the next
%event, left moves to the previous. Double right-click exists the moving
%feature

close all
ttt=figure(1);
sgtitle(strcat("Detected events. Total:",num2str(length(event_peak))))
distance=4;
zoom=0.5;
z=zoom*1.5*zscore(dat(hpc,:));
zz=zoom*0.5*abs(zscore(target))+distance;
if evo==3
    zz=0.5*zscore(target)+distance;
end
plot([0:length(dat(hpc,:))-1]/fs,z,"k","LineWidth",0.000000001)
set(gca,'Color',[238,232,170]/256)
hold on
plot([0:length(data_ar(hpc,:))-1]/fs,zz,"LineWidth",2,"color",[0,128,128]/256)
plot([event_peak(1)],z(timestamp==event_peak(1)),"o","color","red",'MarkerSize',12)
legend('recording','bandpass','event','AutoUpdate','off')
xlabel("Seconds")
show_peak=1;
numme=500;
if size(event_end,1)<=numme
    numme=size(event_end,1);
end
for i=1:numme
plot([event_start(i)],z(timestamp==event_peak(i)),"|","color","magenta",'MarkerSize',12)
end
for i=1:numme
    if abs(z(timestamp==event_peak(i)))<10
        plot([event_peak(i)],z(timestamp==event_peak(i)),"o","color","red",'MarkerSize',12)
    else
        plot([event_peak(i)],0,"o","color","red")
    end
end
for i=1:numme
plot([event_end(i)],z(timestamp==event_peak(i)),"|","color","magenta",'MarkerSize',12)
end
i=0;

i=2;
w=[3,10,30];
ww=w(evo);
axis([event_peak(i)-ww event_peak(i)+ww -4 11])
button=1;
prev=0;
while button==1 %until a right-click occurs
    [x,y,button] = ginput(2);
    axis([event_peak(i)-3 event_peak(i)+3 -4 11])
    if x>=prev
        prev=event_peak(i);
        i=i+1;
    else
        prev=event_peak(i);
        i=i-1;
    end
    pause(0.1)
end

%% save the results
clear data
try
    load (strcat('/home/genzel/Desktop/Emanuele/processed_data/event/',name));
catch
end
data.(file_tp).(ev_tp)=event;
data.name=name;

save_folder=strcat('/home/genzel/Desktop/Emanuele/processed_data/event/',name);
save(save_folder,'data','-v7.3')











