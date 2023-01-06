%toolboxFile = 'chronux_2_12.mltbx';
%installedToolbox = matlab.addons.toolbox.installToolbox(toolboxFile)

%%
clear 
fs = 30000;
for i=1:4
    sig = readmda('/media/genzel/Elements/hm_spikesorting/Preprocess/Rat1_20201018/Rat_Hm_Ephys_Rat1_389236_20201018_maze_merged_nt30_Preprocess.mda');
    %sig = readmda('/media/genzel/Elements/hm_spikesorting/mda_files/Rat_Hm_Ephys_Rat1_389236_20200904_homecageday.mountainsort/Rat_Hm_Ephys_Rat1_389236_20200904_homecageday.nt30.mda');
    %sig = readmda('/media/genzel/data/spikesorting/Rat/tetrode_recording.nt30.mda');

    sig = transpose(sig);
    ch1 = sig(:,i);
    clear sig
    pre = locdetrend(ch1,fs,[.1 .05]);
    save(['detrendch' num2str(i) '.mat'],'pre','-v7.3')
    clear pre ch120201208
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
mkdir '/media/genzel/Elements/hm_spikesorting/detrending' 'Rat_HM_Ephys_Rat1_389236_20201018_maze_merged_Preprocess_detrend.mda'
output= '/media/genzel/Elements/hm_spikesorting/detrending/Rat_HM_Ephys_Rat1_389236_20201018_maze_merged_Preprocess_detrend.mda/Rat_Hm_Ephys_Rat1_389236_20201018_maze_merged_tetrode_recording.nt30.detrend.mda'
writemda(res,output,'int16');
