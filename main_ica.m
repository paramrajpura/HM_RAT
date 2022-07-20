%% independent component rejection

%% 1 - set up the stage


close all
clear all
addpath('/home/genzel/Desktop/Emanuele')
addpath('/home/genzel/Desktop/Emanuele/artifact_detector')
addpath('/home/genzel/Desktop/Emanuele/artifact_detector/fieldtrip')
cd /home/genzel/Desktop/Emanuele/processed_data/preproc % folder where the downsampled files are stored
% ask the user to select the recording to load
file = uigetfile("title","Select the study day to open"); 
load(file)


recs=data_gen.recs;
IC=data_gen.ic;
varianza=data_gen.variance;
%chan=data_gen.chan;
fs=600;
comp=data_gen.comp;
rat_num=str2num(data_gen.name(17));
pfc=[59,3,0,57,86,0,93,94];
hpc=[6,36,0,74,60,0,66,59];

chan=[pfc(rat_num),hpc(rat_num)]; %rows that correspond to pfc and hpc, respectively
%% 2 - plotting the original data to ask where there is an artifact

close all
gate=true;
while gate
    ttt=figure(1);
    plot1(recs,chan)
    sgtitle('Original recording - close to continue')
    subplot(2,1,1)
    title('PFC')
    subplot(2,1,2)
    title('HPC')
    while ishandle(ttt)
        pause(0.1)
    end
    prompt = {'Select the location (in seconds) of an artifact - -1 to show back the plot'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'1','hsv'};
    art_time = str2num(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
    if art_time >= 0
        gate=false;
    end
end


%% 3 - plot the ICs
close all


[selection] = plot_1(recs,IC,varianza,chan,art_time);

%here I want to firstly only plot the normal channels and ask to select the
%location of an artifact. Then I want to plot the single ICs with a
%spectrogram, and only then I want to ask the user to select the ones to
%remove
%% 4 - Reject the components
close all
data.name=data_gen.name;
clear recs IC data_gen



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


%% 5 - highpass components before removing them
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

%% 6 - recompose the matrix and remove the unnecessary channels

%recompose the data matrix, stacking all the trials together.
for i=1:size(reconstr.trial,2)
    clean(:,1+size(reconstr.trial{1},2)*(i-1):size(reconstr.trial{1},2)*(i))=reconstr.trial{i}(chan,:);
    timestamp(:,1+size(reconstr.trial{1},2)*(i-1):size(reconstr.trial{1},2)*(i))=reconstr.time{i}+(i)*2*reconstr.time{i}(end)-reconstr.time{i}(end-1);
    nclean(:,1+size(reconstr_original.trial{1},2)*(i-1):size(reconstr_original.trial{1},2)*(i))=reconstr_original.trial{i}(chan,:);
end

%% 7 - save the file back

data.cleaned=clean;
data.original=nclean;
data.timestamp=timestamp;
%data.chan=chan_oi;
save_folder=strcat('/home/genzel/Desktop/Emanuele/processed_data/ICA/',data.name);
save(save_folder,'data','-v7.3')

