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

fs=600;
cd /home/genzel/Desktop/Emanuele/processed_data/ICA % folder where the downsampled files are stored
file = uigetfile("title","Select the processed file you want to analyse"); %ask the user to select the recording to load
load(file)

% idcs   = strfind(folder,'/');
% dir_end  = folder(idcs(end-1):idcs(end));
% trimmed=dir_end(2:end-1);
% name_nt=strcat(trimmed,'.nt');
% mkdir('/home/genzel/Desktop/Emanuele/artifact_detector/processed/HM/',trimmed)
% saved=strcat('/home/genzel/Desktop/Emanuele/artifact_detector/processed/HM/',trimmed);
% cd(folder)


prompt = {'Original or ICA-cleaned? 1 = original ; 2 = ICA-cleaned'}; %ask the user: postsleep or presleep?
dlgtitle = 'Input';
dims = [1 35];
definput = {'2'};
dt = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
chan=data.chan;
pfc=chan(1);
hpc=chan(2);
if dt==1
    data=data.original;
elseif dt==2
    data=data.cleaned;
end


prompt = {'Which event are you interested in? 1 = ripple; 2 = spindle; 3 = delta'}; %ask the user: postsleep or presleep?
dlgtitle = 'Input';
dims = [1 35];
definput = {'1'};
channel_oi = inputdlg(prompt,dlgtitle,dims,definput);
evo=str2num(channel_oi{1});


%data=cell2mat(struct2cell(load(file)));


%clearvars -except data pfc hpc fs saved

%% call the bandpass function

close all
data_bp = bandpass_custom(data,fs,evo);
%plot1(data_bp,1)
%% Detect the events

clear ripple spindle delta

timestamp=[0:length(data(hpc,:))-1/fs]/fs;

if evo==1
    event = FindRipples([timestamp;data(hpc,:)]');
    event_start=event(:,1);
    event_peak=event(:,2);
    event_end=event(:,3);   
elseif evo==2
    event=FindSpindles([timestamp;data(hpc,:)]');
    event_start=event(:,1);
    event_peak=event(:,2);
    event_end=event(:,3); 
elseif evo==3
    event=FindDeltaWaves([timestamp;data(hpc,:)]');
    event_start=event(:,1);
    event_peak=event(:,2);
    event_end=event(:,3); 
end


 

%% Manual event detection
gate=false;
if gate
    clear manual th
    manual=manual_event_detection(data,data_bp,hpc,fs);
    if length(manual)<=0
        clear manual
    end
end
%th=max(abs(data_bp(hpc,round(manual))));
%magari, interessante, aggiungi la cosa che ti viene detto il threshold
%minimo necessario per detectare tutti gli eventi

%% creates a logical vector of when the events are detected
timestamp=[1:length(data(1,:))]/600;
is_event=zeros(size(timestamp));
is_event_old=zeros(size(timestamp));
for i=1:length(event_start)
    temp=timestamp>=event_start(i) & timestamp<=event_end(i);
    is_event=temp+is_event;
end

clearvars i temp

%% Plot the detected ripples with also the ones manually detected to see how the function performed

if exist('manual')
    plot_compare_eventdetect(data(hpc,:),data_bp(hpc,:),manual,event_peak)
end
%% Find the differentially detected ripples
% not usable now, can be used to compare two version of artifact removed
% data
% 
% is_event=zeros(size(timestamp));
% is_event_old=zeros(size(timestamp));
% for i=1:length(event_start)
%     temp=timestamp>=event_start(i) & timestamp<=event_end(i);
%     is_event=temp+is_event;
% end
% clear temp
% for i=1:length(ripple_start_old)
%     temp=timestamp>=ripple_start_old(i) & timestamp<=ripple_end_old(i);
%     is_event_old=temp+is_event_old;
% end
% 
% is_difference=is_event~=is_event_old;
% 
% is_same_peak=zeros(size(timestamp));
% clear ripple_not_old
% j=1;
% for i=1:length(event_peak)
%     p=find(timestamp==event_peak(i));
%     if is_event_old(p)==0
%         ripple_not_old(j)=timestamp(p);
%         j=j+1;
%     end
% end
% 
% clear ripple_not_new
% j=1;
% for i=1:length(ripple_peak_old)
%     p=find(timestamp==ripple_peak_old(i));
%     if is_event(p)==0
%         ripple_not_new(j)=timestamp(p);
%         j=j+1;
%     end
% end
% j=1;
% for i=1:length(event_peak)
%     if sum(event_peak(i)==ripple_not_old)==0 & sum(event_peak(i)==ripple_not_new)==0
%         ripple_common(j)=event_peak(i);
%         j=j+1;
%     end
% end


%% plot the cleaned and bp signal with differentially detected ripples
% close all
% figure
% plot([0:length(data(hpc,1:1000*fs))-1]/fs,7*zscore(data(hpc,1:1000*fs)))
% hold on
% plot([0:length(data(hpc,1:1000*600))-1]/fs,2*zscore(cleaned_bp(hpc,1:1000*fs))+60)
% xlabel("Seconds")
% 
% plot([ripple_not_new(1),ripple_not_new(1)],[-50 120],"--","color","red")
% plot([ripple_not_old(1),ripple_not_old(1)],[-50 120],"--","color","green")
% plot([ripple_common(1),ripple_common(1)],[-50 120],"--","color","black")
% 
% for i=1:length(ripple_not_new)
%     plot([ripple_not_new(i),ripple_not_new(i)],[-50 120],"--","color","red")
% end
% for i=1:length(ripple_not_old)
%     plot([ripple_not_old(i),ripple_not_old(i)],[-50 120],"--","color","green")
% end
% for i=1:length(ripple_common)
%     plot([ripple_common(i),ripple_common(i)],[-50 120],"--","color","black")
% end
% axis([100 112 -30 90])
% title("Original vs filtered ripple detection comparison")
% legend("cleaned signal","bandpassed signal","only detected in original signal","only detected in cleaned signal","detected in both")
% 


%% plot start, peak and end of the ripples to try understand something
close all
figure
sgtitle("Ripples detected in the cleaned signal")
distance=10;
z=7*zscore(data(hpc,:));
zz=4*zscore(data_bp(hpc,:))+distance;
plot([0:length(data(hpc,:))-1]/fs,z,"k","LineWidth",0.000000001)
hold on
plot([0:length(data(hpc,:))-1]/fs,zz,"color",[0 0.4470 0.7410])

xlabel("Seconds")
show_peak=1;
numme=40;
if size(event_end,1)<=numme
    numme=size(event_end,1);
end
for i=1:numme
plot([event_start(i)],z(timestamp==event_peak(i)),"|","color","magenta")
end
for i=1:numme
    if abs(z(timestamp==event_peak(i)))<20
        plot([event_peak(i)],z(timestamp==event_peak(i)),"*","color","red")
    else
        plot([event_peak(i)],0,"*","color","red")
    end
end
for i=1:numme
plot([event_end(i)],z(timestamp==event_peak(i)),"|","color","magenta")
end
for i=1:length(event_peak)
 axis([event_peak(i)-3 event_peak(i)+3 -10 20])
 pause(2)
end
%%
clear event_f
load events
event_f.timestamp=timestamp;
if evo==1
    event_f.ripple=event;
elseif evo==2
    event_f.spindle=event;
elseif evo==3
    event_f.delta=event;
end

nam=strcat(folder,'/events');
save(nam,'event_f')















