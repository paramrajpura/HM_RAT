%% independent component rejection


% close all
% clear all


cd /home/genzel/Desktop/Emanuele/processed_data/preproc % folder where the downsampled files are stored
% ask the user to select the recording to load
file = uigetfile("title","Select the study day to open"); 
load(file)


recs=data_gen.recs;
IC=data_gen.ic;
varianza=data_gen.variance;
chan=data_gen.chan;
fs=600;
%% 5 - plotting the original data to ask where there is an artifact

close all
plot1(recs,chan)
sgtitle('Original recording')
subplot(2,1,1)
title('PFC')
subplot(2,1,2)
title('HPC')

prompt = {'Select the location (in seconds) of an artifact'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1','hsv'};
art_time = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));

%% plot information on the ICs

close all
           % Sampling frequency                    
T = 1/fs;             % Sampling period       
L = size(IC,2);             % Length of signal
t = (0:L-1)*T;        % Time vector

for i=1:4
    j=2; %change to show other ICs
    subplot(2,2,i)
    show_IC=i+j;
    x=fft(IC(show_IC,:));

    P2 = abs(x/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = fs*(0:(L/2))/L;
    plot(f,P1) 
    title('IC nr.',i+j)

    xlabel('Frequency')
end
% I would do so: take the fft of all the ICs, sum the values in the event
% frequency bands and use it to determine how much of that frequency each
% component is carrying
%%
gate=false;
if gate
    close all

    spectrogram(IC(1,:),[],[],fs)
end

%%
close all


[selection] = plot_1(recs,IC,varianza,chan,art_time);

%here I want to firstly only plot the normal channels and ask to select the
%location of an artifact. Then I want to plot the single ICs with a
%spectrogram, and only then I want to ask the user to select the ones to
%remove
%% 6 - Reject the components

for i=1:2 
    cfg = [];
    if i==1
        cfg.component = []; % to be removed component(s) for reconstruction 1
    else
        cfg.component = setdiff([1:size(comp.topo,2)],selection,'stable'); % to be removed component(s) for reconstruction 2
    end
    reconstr = ft_rejectcomponent(cfg, comp);
    if i==1
        reconstr_original=reconstr;
    end
end
% close all
% plot1(cleaned/mean(abs(cleaned(hpc,:))),hpc)
% plot1(cleaned_not/mean(abs(cleaned_not(hpc,:))),hpc,'r')
% % a=real(reconstr.trial{1});
% % b=real(reconstr_original.trial{1});
% % plot2(a/mean(a),b/mean(b),chan)
% subplot(length(chan),1,1)
% sgtitle('ICA-cleaned vs original signal')
% title("PFC")
% subplot(length(chan),1,2)
% title("HPC")
% legend("Original","zero","ICA-cleaned")
% 
% %recompose the data matrix, stacking all the trials together.
% for i=1:size(reconstr.trial,2)
%     cleaned(:,1+size(reconstr.trial{1},2)*(i-1):size(reconstr.trial{1},2)*(i))=reconstr.trial{i};
%     timestamp(:,1+size(reconstr.trial{1},2)*(i-1):size(reconstr.trial{1},2)*(i))=reconstr.time{i}+(i)*2*reconstr.time{i}(end)-reconstr.time{i}(end-1);
%     cleaned_not(:,1+size(reconstr_original.trial{1},2)*(i-1):size(reconstr_original.trial{1},2)*(i))=reconstr_original.trial{i};
% end
% 
% s_clean=strcat(saved,'/processed_ICA');
% s_nclean=strcat(saved,'/processed_original');
% save(s_clean,'cleaned')
% save(s_nclean,'cleaned_not')

%% 7 - highpass components before removing them
gate=false;
if gate
    IC_to_remove=[];
    save_comp=comp;
    for i=1:length(IC_to_remove)
        for j=1:size(comp.trial{IC_to_remove(i)},1)
        comp.trial{IC_to_remove(i)}(j,:)=bandpass(comp.trial{IC_to_remove(i)}(j,:),[50 299],600);
        end
    end
end
%% remove outliers
gate=false;
if gate
    j=1;
    figure(1)
    for i=0:1/10:10
    outlier=abs(cleaned)>=std(cleaned)*i;
    removed1(j)=sum(sum(outlier))/size(cleaned,1)/size(cleaned,2);
    j=j+1;
    end
    plot([0:length(removed1)-1]/10,removed1*100,"LineWidth",2,"color","b")
    title("percentage of outliers of original vs cleaned data")
    ylabel("outliers, percentage")
    xlabel("standard deviation")

    j=1;
    for i=0:1/10:10
    outlier=abs(recs)>=std(recs)*i;
    removed2(j)=sum(sum(outlier))/size(recs,1)/size(recs,2);
    j=j+1;
    end
    hold on
    plot([0:length(removed2)-1]/10,removed2*100,"LineWidth",2,"color","r")
    title("percentage of outliers of original data")
    ylabel("outliers, percentage")
    xlabel("standard deviation")
end

%% save

%recompose the data matrix, stacking all the trials together.
for i=1:size(reconstr.trial,2)
    cleaned(:,1+size(reconstr.trial{1},2)*(i-1):size(reconstr.trial{1},2)*(i))=reconstr.trial{i};
    timestamp(:,1+size(reconstr.trial{1},2)*(i-1):size(reconstr.trial{1},2)*(i))=reconstr.time{i}+(i)*2*reconstr.time{i}(end)-reconstr.time{i}(end-1);
    cleaned_not(:,1+size(reconstr_original.trial{1},2)*(i-1):size(reconstr_original.trial{1},2)*(i))=reconstr_original.trial{i};
end

data.cleaned=cleaned;
data.original=cleaned_not;
data.timestamp=timestamp;
data.name=data_gen.name;
data.chan=chan;
save_folder=strcat('/home/genzel/Desktop/Emanuele/processed_data/ICA/',data_gen.name);
save(save_folder,'data','-v7.3')

