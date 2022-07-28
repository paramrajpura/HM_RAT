toolboxFile = 'chronux_2_12.mltbx';
installedToolbox = matlab.addons.toolbox.installToolbox(toolboxFile)

%%
clear 
fs = 30000;
for i=1:4
    %sig = readmda('/mnt/genzel/Rat/HM/Rat_HM_Ephys/Preprocess/Rat4_20201109/Rat_Hm_Ephys_Rat4_389239_20201109_Maze_merged_nt30_Preprocess.mda');
    sig = readmda('/media/genzel/data/spikesorting/Rat/tetrode_recording.nt30.mda');

    sig = transpose(sig);
    ch1 = sig(:,i);
    clear sig
    pre = locdetrend(ch1,fs,[.1 .05]);
    save(['detrendch' num2str(i) '.mat'],'pre','-v7.3')
    clear pre ch1
end
%%

ch1 = load('detrendch1.mat','-mat','pre');
ch2 = load('detrendch2.mat','-mat','pre');
ch3 = load('detrendch3.mat','-mat','pre');
ch4 = load('detrendch4.mat','-mat','pre');
pre = [ch1.pre,ch2.pre,ch3.pre,ch4.pre];
clear ch1 ch2 ch3 ch4
res = transpose(pre);
%%
clear pre
writemda(res,'tetrode_recording.nt30detrend.mda','int16');