%% Script that creates figures 

%% initialize
clear all
close all
clc

%% 
folder= 'C:\Users\Emanuele\Desktop\uni\event'; %specify the path to files
file=dir;

%initialize the variables
ripple.hc=[];
ripple.en=[];
ripple.re=[];
spindle.hc=[];
spindle.en=[];
spindle.re=[];
delta.hc=[];
delta.en=[];
delta.re=[];

%loop over the files in the directory
for i=1:length(file)
	%the loop continues if the file name is correct
	if ~startsWith(file(i).name,'Rat_Hm_Ephys_Rat')
        continue
    end
    %the loop continues only for postsleep files
    if ~endsWith(file(i).name,'postsleep.mat')
        continue
    end
    load(file(i).name) %load the i-th file
    file(i).name
    %extract the time of sleep minus the artefact removed
    sleep=round(sum(data.sleepscore==3)-data.artefact/600)/60; %divide by 60 to get it in minutes
    %get ripple count per condition
    if sum(ismember([1,2,4],str2num(data.name(17)))) %only for certain rats
        if strcmp(data.condition,'homecage')
            ripple.hc=[ripple.hc,size(data.ripple,1)];
            rip_rate.hc=[ripple.hc,size(data.ripple,1)]/sleep;
        elseif strcmp(data.condition,'encoding')
            ripple.en=[ripple.en,size(data.ripple,1)];
            rip_rate.en=[ripple.en,size(data.ripple,1)]/sleep;
        elseif strcmp(data.condition,'retrieval')
            ripple.re=[ripple.re,size(data.ripple,1)];
            rip_rate.re=[ripple.re,size(data.ripple,1)]/sleep;
        end
    end
    
    %get spindle count per condition
    if strcmp(data.condition,'homecage')
        spindle.hc=[spindle.hc,size(data.spindle,1)];
        spin_rate.hc=[spindle.hc,size(data.spindle,1)]/sleep;
    elseif strcmp(data.condition,'encoding')
        spindle.en=[spindle.en,size(data.spindle,1)];
        spin_rate.en=[spindle.en,size(data.spindle,1)]/sleep;
    elseif strcmp(data.condition,'retrieval')
        spindle.re=[spindle.re,size(data.spindle,1)];
        spin_rate.re=[spindle.re,size(data.spindle,1)]/sleep;
    end
    
    %get delta count per condition
    if strcmp(data.condition,'homecage')
        delta.hc=[delta.hc,size(data.delta,1)];
        delta_rate.hc=[delta.hc,size(data.delta,1)]/sleep;
    elseif strcmp(data.condition,'encoding')
        delta.en=[delta.en,size(data.delta,1)];  
        delta_rate.en=[delta.en,size(data.delta,1)]/sleep;
    elseif strcmp(data.condition,'retrieval')
        delta.re=[delta.re,size(data.delta,1)];
        delta_rate.re=[delta.re,size(data.delta,1)]/sleep;
    end
end

%% calculate Standard Error Deviation (SEM)

%SEM for event counts
SEM_rip_hc = std(ripple.hc)/sqrt(length(ripple.hc));
SEM_rip_en = std(ripple.en)/sqrt(length(ripple.en));
SEM_rip_re = std(ripple.re)/sqrt(length(ripple.re));
SEM_rip_h = [SEM_rip_hc,SEM_rip_en,SEM_rip_re];
SEM_rip_l = [SEM_rip_hc,SEM_rip_en,SEM_rip_re];

SEM_spin_hc = std(spindle.hc)/sqrt(length(spindle.hc));
SEM_spin_en = std(spindle.en)/sqrt(length(spindle.en));
SEM_spin_re = std(spindle.re)/sqrt(length(spindle.re));
SEM_spin_h = [SEM_spin_hc,SEM_spin_en,SEM_spin_re];
SEM_spin_l = [SEM_spin_hc,SEM_spin_en,SEM_spin_re];

SEM_delta_hc = std(delta.hc)/sqrt(length(delta.hc));
SEM_delta_en = std(delta.en)/sqrt(length(delta.en));
SEM_delta_re = std(delta.re)/sqrt(length(delta.re));
SEM_delta_h = [SEM_delta_hc,SEM_delta_en,SEM_delta_re];
SEM_delta_l = [SEM_delta_hc,SEM_delta_en,SEM_delta_re];

%SEM for event rates
SEM_rip_hc = std(rip_rate.hc)/sqrt(length(rip_rate.hc));
SEM_rip_en = std(rip_rate.en)/sqrt(length(rip_rate.en));
SEM_rip_re = std(rip_rate.re)/sqrt(length(rip_rate.re));
SEM_riprate_h = [SEM_rip_hc,SEM_rip_en,SEM_rip_re];
SEM_riprate_l = [SEM_rip_hc,SEM_rip_en,SEM_rip_re];

SEM_spin_hc = std(spin_rate.hc)/sqrt(length(spin_rate.hc));
SEM_spin_en = std(spin_rate.en)/sqrt(length(spin_rate.en));
SEM_spin_re = std(spin_rate.re)/sqrt(length(spin_rate.re));
SEM_spinrate_h = [SEM_spin_hc,SEM_spin_en,SEM_spin_re];
SEM_spinrate_l = [SEM_spin_hc,SEM_spin_en,SEM_spin_re];

SEM_delta_hc = std(delta_rate.hc)/sqrt(length(delta_rate.hc));
SEM_delta_en = std(delta_rate.en)/sqrt(length(delta_rate.en));
SEM_delta_re = std(delta_rate.re)/sqrt(length(delta_rate.re));
SEM_deltarate_h = [SEM_delta_hc,SEM_delta_en,SEM_delta_re];
SEM_deltarate_l = [SEM_delta_hc,SEM_delta_en,SEM_delta_re];
%% create the plots
close all

X = categorical({'Ripple','Spindle','Delta'});
X = reordercats(X,{'Ripple','Spindle','Delta'});
WerrH=[SEM_rip_h;SEM_spin_h;SEM_delta_h];
WerrL=[SEM_rip_l;SEM_spin_l;SEM_delta_l];

figure(1)
sgtitle('Event Counts')
values_hc=[mean(ripple.hc),mean(spindle.hc),mean(delta.hc)]';
values_en=[mean(ripple.en),mean(spindle.en),mean(delta.en)]';
values_re=[mean(ripple.re),mean(spindle.re),mean(delta.re)]';
values=[values_hc,values_en,values_re]';
hBar = bar(values, 0.8); % Return ‘bar’ Handle
for k1 = 1:size(values,2)
    ctr(k1,:) = bsxfun(@plus, hBar(k1).XData, hBar(k1).XOffset');
    ydt(k1,:) = hBar(k1).YData; % Individual Bar Heights
end
hold on
errorbar(ctr, ydt, WerrL, WerrH, '.', 'MarkerSize',0.25,'color','black')
legend('ripple','spindle','delta')
set(gca,'XTickLabel',{'homecage','encoding','retrieval'});
ylabel('events')


figure(2)
WerrH=[SEM_riprate_h;SEM_spinrate_h;SEM_deltarate_h];
WerrL=[SEM_riprate_l;SEM_spinrate_l;SEM_deltarate_l];
sgtitle('Event Rates')
values_hc=[mean(rip_rate.hc),mean(spin_rate.hc),mean(delta_rate.hc)]';
values_en=[mean(rip_rate.en),mean(spin_rate.en),mean(delta_rate.en)]';
values_re=[mean(rip_rate.re),mean(spin_rate.re),mean(delta_rate.re)]';
values=[values_hc,values_en,values_re]';
hBar = bar(values, 0.8);                                                     % Return ‘bar’ Handle
for k1 = 1:size(values,2)
    ctr(k1,:) = bsxfun(@plus, hBar(k1).XData, hBar(k1).XOffset');
    ydt(k1,:) = hBar(k1).YData;  % Individual Bar Heights
end
hold on
errorbar(ctr, ydt, WerrL, WerrH, '.', 'MarkerSize',0.25,'color','black')
legend('ripple','spindle','delta')
set(gca,'XTickLabel',{'homecage','encoding','retrieval'});
ylabel('events/NREM(minutes)')
