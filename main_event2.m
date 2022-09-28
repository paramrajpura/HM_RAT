%main_event script that also does the NREM

%first: select the files. In this case they are .mda files, contrarly to
%the previos main_event that relied on preprocessing

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

% specify the channels to use per animal. Each row is an animal. First two
% columns are tetrode and channel for PFC, the last two for HPC
channels=[
    30,3,13,2   %rat1
    13,3,24,4   %rat2
    0,0,0,0     %rat3
    30,1,8,2    %rat4
    29,2,22,4   %rat5
    0,0,0,0     %rat6
    30,1,24,2   %rat7
    20,2,22,3   %rat8
    ];
fs=600; %sampling frequency
thresh=[
    2.5,1.5,0.2 %rat1
    2.5,1.5,0.2 %rat2
    3,1.5,0.6 %rat3
    2.5,1.5,0.2 %rat4
    4.5,1.5,0.6 %rat5
    3,1.5,0.6 %rat6
    4.5,1.5,0.2 %rat7
    4.5,1.5,0.8 %rat8
    ];
%specify the file names; the files are arranged so that the first column
%contains the homecage condition, the second the encoding condition and the
%third the retrieval condition
file_names={
    'Rat_Hm_Ephys_Rat1_389236_20200904','Rat_Hm_Ephys_Rat1_389236_20200909','Rat_Hm_Ephys_Rat1_389236_20200911';
    'Rat_Hm_Ephys_Rat2_389237_20200910','Rat_Hm_Ephys_Rat2_389237_20200915','Rat_Hm_Ephys_Rat2_389237_20200917';
    'Rat_Hm_Ephys_Rat4_389239_20201104','Rat_Hm_Ephys_Rat4_389239_20201109','Rat_Hm_Ephys_Rat4_389239_20201111';
    'Rat_Hm_Ephys_Rat5_406576_20210609','Rat_Hm_Ephys_Rat5_406576_20210612','Rat_Hm_Ephys_Rat5_406576_20210614';
    'Rat_Hm_Ephys_Rat7_406578_20210714','Rat_Hm_Ephys_Rat7_406578_20210720','Rat_Hm_Ephys_Rat7_406578_20210722';
    'Rat_Hm_Ephys_Rat8_406579_20210821','Rat_Hm_Ephys_Rat8_406579_20210803','Rat_Hm_Ephys_Rat8_406579_20210810'
    }; 
thresh_backup=thresh;
tr_art=10; %Select the threshold for detecting and removing artefacts based on amplitude. Default : 10
tr_dis=13; % Select the threshold for detecting and removing discontinuities. Default : 13
resetting_detection=[5,7,8]; %specify for which rats you want to remove the resetting artefacts
band_stop=false; %set to true if the signal requires 50 hz and harmonics noise removal
%%
cd  /mnt/genzel/Rat/HM/Rat_HM_Ephys/mda_extracted_presleep_EC % folder where the downsampled files are stored
files = uipickfiles; %ask the user to select the recording to load
j=1;
for i=1:length(files)
    cd(files{i})
    a=dir;
    for ii=1:3%length(a)
        if strfind(a(ii).name,'StudyDay')
            disp(ii);
            file{j}=strcat(files{i},'/',a(ii).name);
            if ~isempty(file{j})
                j=j+1;
            end
        end
        continue
    end
end

%%
for st=1:length(file) %loop over study days
    clearvars -except channels fs thresh tr_art tr_dis file st resetting_detection thresh_backup band_stop file_names
    thresh=thresh_backup;
    cd (file{st})
    tr_file=dir;
    a=cell2mat(strfind(file,'Rat_Hm_Ephys_Rat'));
    rat_nr=str2num(file{st}(a(1)+16));
    chan_oi=channels(rat_nr,:);
    for i=1:length(tr_file) %loop over tetrode files
        name=tr_file(i).name;
        tr=name(strfind(name,'.nt')+3:end);
        tr=str2num(tr(1:strfind(tr,'.mda')-1));
        if tr==chan_oi(1)
            temp=readmda(name);
            rec(1,:)=temp(chan_oi(2),:);
        elseif tr==chan_oi(3)
            temp=readmda(name);
            rec(2,:)=temp(chan_oi(4),:);
        end
    end
    % bandstop 50hz and harmonics. Only do if the noise is present in the
    % periodogram

    if band_stop
        close all
        periodogram(rec(1,:),rectwin(length(rec(1,:))),length(rec(1,:)),600);
        title('periodogram of original recording')
        fr=51;
        rec2=bandstop(rec(1,:),[fr-2 fr+0],600);
        rec2=bandstop(rec2,[fr*2-1 fr*2+1],600);
        rec2=bandstop(rec2,[fr*3-1 fr*3+1],600);
        rec2=bandstop(rec2,[fr*4-1 fr*4+1],600);
        rec2=bandstop(rec2,[fr*5-1 fr*5+1],600);
        figure(2)
        title('after 50hz and harmonics bandstop')
        periodogram(rec2(1,:),rectwin(length(rec(1,:))),length(rec(1,:)),600);
    end

        
    %load the sleepscoring file
    sl_dir='/mnt/genzel/Rat/HM/Rat_HM_Ephys'; %sleep directory
    cd(sl_dir)
    a=dir;
    for ii=1:length(a)
        if strfind(a(ii).name,strcat('Rat',num2str(rat_nr)))
            sl_dir=strcat(sl_dir,'/',a(ii).name);
            break
        end
        
    end
    cd(sl_dir)
    a=dir;
    for iii=1:length(a)
        if strfind(a(iii).name,file{st}(end-7:end))
            sl_dir=strcat(sl_dir,'/',a(iii).name);
        end
    end
    sl_time='homecageday';
    if strfind(file{st},'presleep')
        sl_time='presleep';
        sl_temp='presleep';
    elseif findstr(file{st},'postsleep')
        sl_time='postsleep';
        sl_temp='postsleep';
    end
    if rat_nr<=5
        tr_dis=9999999;
    else 
        tr_dis=13;
    end
   
    if strfind(file{st},'postsleep/Rat_Hm_Ephys_Rat1_389236_20200904_homecageday')
        sl_time='homecage';
    end
    if strfind(file{st},'presleep_EC/Rat_Hm_Ephys_Rat1_389236_20200904_homecageday')
        sl_time='homecage';
    end

    cd(sl_dir)
    a=dir;
    for iiii=1:length(a)
        if strfind(a(iiii).name,sl_time)
            
            filename=a(iiii).name;
            
            if findstr(filename,'.')
                filename=filename(1:findstr(filename,'.')-1);
                try
                    filename=strcat(filename(1:findstr(filename,'homecage')-1),sl_temp);
                catch
                end
            end

            if ~strcmp(sl_time,'homecage')
                sl_dir=strcat(sl_dir,'/',a(iiii).name);
            end
            break
        end       
    end
    cd(sl_dir)
    a=dir;
    for i=1:length(a)
        if strfind(a(i).name,'eegstates.mat')
            load(a(i).name)
        end
    end
    states(end+1:3600*4)=zeros;
    states=states(1:size(rec,2)/fs);
    states_ex=reshape(repmat(states,fs,1),1,[]);
    recs=rec(:,states_ex==3);
    if size(recs,2)<=0
        continue
    end
    % if the file is a presleep, load the threshold used for the postsleep
%     if strfind(file{st},'presleep')
%         cd '/home/genzel/Desktop/Emanuele/processed_data/event'
%         load(strcat(filename(1:end-8),'postsleep'))
%         std_post=data.std;
%         thresh_post=data.thresholds;
%         clear data
%         thresh(:,1)=thresh(:,1)*std_post(2)/std(recs(2,:));
%         thresh(:,2:3)=thresh(:,2:3)*std_post(1)/std(recs(1,:));
%     end
    for i=1:3
        data_bp([(i-1)*2+1:i*2],:)=bandpass_custom(recs,fs,i);
    end
    
    %% artefact removal
    trr=tr_art*mean(abs([recs(1,:),recs(2,:)]));
    % select the portion of the signal to substitute
    %After having detected the timepoints in which the signal surpasses the
    %threhsold, it is necessary to create a window before and after those
    %timepoints (that because of the oscillatory nature of the artefacts)

    det_t=sum(abs([recs(1,:);recs(2,:)])>=trr); %logic-like vector: a non-zero integer signifies that
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

    
    %% detect discontinuities. 
    %the approach is the same of the previous threshold-based artefact
    %detection, but 1) it will now consider the first derivative, instead of
    %the simple signal and 2) it will have a different window, since often
    %times the signal before the discontinuity if fine
    
    tr_d=tr_dis*mean(mean([abs(diff(recs(1,:)));abs(diff(recs(2,:)))]));   
    %% same procedure of the one for the threshold-based artefact detector, but for the discontinuities
    det_t=sum([abs(diff(recs(1,:)));abs(diff(recs(2,:)))]>=tr_d);

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
    
    %% detect resetting artefact
    %the approach is the same of the previous threshold-based artefact
    %detection, but 1) it will now consider the first derivative, instead of
    %the simple signal and 2) it will have a different window, since often
    %times the signal before the discontinuity if fine

    if sum(ismember(resetting_detection,rat_nr))>=1
        det_ttt=resetting_artefact(recs(1,:));
    else
        det_ttt=zeros(size(recs(1,:)));
    end
    %% same procedure of the one for the threshold-based artefact detector, but for the resetting artefact
    det_ttta=det_ttt;
    win=0.1*fs; %window that cuts out before the discontinuity
    for jjj=1:win
        det_ttta=det_ttta+[det_ttt(jjj:end) zeros(1,jjj-1)];
    end
    win=2.5*fs; %window that cuts out after the discontinuity
    for jjj=1:win
        det_ttta=det_ttta+[zeros(1,jjj-1) det_ttt(1:end-jjj+1) ];
    end
    %% substitute the artifacts with the average
    if ~exist('det_td')
        det_td=zeros(size(det_tt)-1);
    end
    det_ttd=or(or(det_tt,[det_td,0]),det_ttta);
    data_ar=data_bp;
    for i=1:6
        data_ar(i,det_ttd)=mean(data_ar(i,:));
    end
    %% divide the recording into bouts of NREM sleep
    % this will be useful for event detection: it allows to avoid
    % discontinuities in the signal

    state=states; %initialize 'state' equal to the sleepscoring vector 
    % [reminder: the states vector is 1Hz, and each timepoint is an integer. 
    % 1=wake; 2=artefact; 3=NREM; 4=intermediate; 5=REM]
    clear bout
    jj=1;
    while true
        try
            state=state(find(state==3,1):end); %trim 'state' until the first NREM timeframe
            bout(jj)=find(state~=3,1)-1; %the bout is then from 1 to the first non-NREM timeframe -1
        catch
            break %the try-catch allows to stop the while loop when it's done
        end
        state=state(bout(jj)+1:end); %'state' is now trimmed to exclude the bout just detected
        jj=jj+1;
    end
    bout=[1,[cumsum(bout)]*600]; %cumulative of bout to make it match with the signal
    
    %event detection
    %ripple detection
    timestamp=[bout(1)+1:bout(end)+1]/fs;
    data_ar=[data_ar,zeros(6,bout(end)-size(recs,2))]; %it is necessary to zero-pad the signal to make it match with the length of the bouts

    thr=std(data_ar(2,:))*thresh(rat_nr,1); %the threshold is a function of the std of the signal


        
    ripple=[];
    for j=1:length(bout)-1
        [ripple_st,ripple_peak,ripple_end]=findRipplesLisa(data_ar(2,bout(j):bout(j+1)),timestamp(bout(j):bout(j+1)),thr,thr/2,fs);
        ripple=[ripple';[ripple_st;ripple_end;ripple_peak]']'; %store the detected events by appending the 'event' variable to itself  
    end
    ripple=ripple';
    %spindle detection
    target=data_ar(3,:);
    timestamp=[1:length(target)]/fs;
    spindle=FindSpindles([timestamp;target]','peak',thresh(rat_nr,2)*2,'threshold',3.5); %default: peak=5: threshold=2.5

    target=data_ar(5,:);
    timestamp=[1:length(target)]/fs;
    delta=FindDeltaWaves([timestamp;target]',thresh(rat_nr,3));
    
    clear data
    try
        load (strcat('/home/genzel/Desktop/Emanuele/processed_data/event/',name));
    catch
    end
    timestamp_whole=[1:size(rec,2)]/fs;
    time2=NaN(size(timestamp_whole));
    time2(states_ex==3)=timestamp;
    for kk=1:size(ripple,1)
            %pos_ripple(kk)=find(ripple(kk,2)==time2);
            pos_ripple(kk)=timestamp_whole(find(ripple(kk,2)==time2));
    end
    for kk=1:size(spindle,1)
            pos_spindle(kk)=timestamp_whole(find(spindle(kk,2)==time2));
    end
    for kk=1:size(delta,1)
            pos_delta(kk)=timestamp_whole(find(delta(kk,2)==time2));
    end
    
    data.('ripple')=ripple;
    data.('spindle')=spindle;
    data.('delta')=delta;
    for kj=1:4
            data.('rippleXhr').(strcat('hour',num2str(kj)))=[];
            data.('spindleXhr').(strcat('hour',num2str(kj)))=[];
            data.('deltaXhr').(strcat('hour',num2str(kj)))=[];
        try
            data.('rippleXhr').(strcat('hour',num2str(kj)))=ripple(ceil(pos_ripple/3600)==kj);
        catch
        end
        try
            data.('spindleXhr').(strcat('hour',num2str(kj)))=ripple(ceil(pos_spindle/3600)==kj);
        catch
        end
        try
            data.('deltaXhr').(strcat('hour',num2str(kj)))=ripple(ceil(pos_delta/3600)==kj);
        catch
        end
    end
    data.name=filename;
    data.bouts=bout;
    data.sleepscore=states;
    data.artefact=sum(det_ttd);
    data.thresholds=thresh(rat_nr,:);
    data.std=[std(recs(1,:)),std(recs(2,:))];
    clear temp
    temp={};
   
    for i=1:size(ripple,1)
        temp(1,end+1)={data_ar(2,find(timestamp==ripple(i,1)):find(timestamp==ripple(i,3)))};
    end
    data.ripple_array=temp;
    temp={};
    for i=1:size(spindle,1)
        temp(1,end+1)={data_ar(3,find(timestamp==spindle(i,1)):find(timestamp==spindle(i,3)))};
    end
    data.spindle_array=temp;
    temp={};
    for i=1:size(delta,1)
        temp(1,end+1)={data_ar(5,find(timestamp==delta(i,1)):find(timestamp==delta(i,3)))};
    end
    data.delta_array=temp;
    data.original=recs;
    data.bandpass=data_ar;
    
    % add information about experimental conditioncond=strfind(file_names,filename(1:end-9));
    cond=strfind(file_names,filename(1:33));
    if sum(cell2mat(cond(:,1)))==1
        data.condition='homecage';
    elseif sum(cell2mat(cond(:,2)))==1
        data.condition='encoding';
    elseif sum(cell2mat(cond(:,3)))==1
        data.condition='retrieval';
    end

    %save the file
    save_folder=strcat('/mnt/genzel/Rat/HM/Rat_HM_Ephys/event_detection/',filename);
    save(save_folder,'data','-v7.3')
    save_folder=strcat('/home/genzel/Desktop/Emanuele/processed_data/event/',filename);
    save(save_folder,'data','-v7.3')
    disp(strcat('Study day: ',filename,' completed'))
    
end