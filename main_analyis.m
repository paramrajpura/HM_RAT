% perfo1rm analysis on the detected events

% I guess the steps are:
% -load the files. Which ones? All of them, only 1 rat, only 1 study day?
% -train analysis
% -sleep analysis (that's simply, maybe number of transitions and total sleep)
% -plot stuff. Firstly, number of events. Than trains, sleep and whatever I can think of.

clear all

%open all the files in the folder
fs=600;
path='/home/genzel/Desktop/Emanuele/processed_data/event';
cd(path)
a=dir;
art_handling={'original','ICA_cl'}; 
old=0;
exp_var=1;
exp_gr=['a','b','c']; %a=homecage, b=learning, c=retrieval
rat_nr=[1,2,4,5,7];
for i=3:length(a)
    load(a(i).name) %load the file
    name=data.name(14:33); %save the name of the file (select the relevant portion of it)
    rat_n=name(4); %nr of the rat (so 1,2,4,5,6 or 7)
        
    if rat_n==old %if the rat nr. is the same in different interations, the experimental
        %manipulation changes from a=homecage, b=learning, c=retrieving
        exp_var=1+exp_var;
    else
        exp_var=1;
    end
    old=rat_n;
    
    for j=1%:2 %artefact handling procedure. ICA is not used anymore
        type_oi=cell2mat(art_handling(j));
        ripple=data.(type_oi).ripple;
        spindle=data.(type_oi).spindle;
        delta=data.(type_oi).delta;

        train_rd=trainp2p(ripple(:,2),delta(:,2),[-250/fs -50/fs]);
        train_ds=trainp2p(delta(:,2),spindle(:,2),[-1300/fs -100/fs]);
        train_dr=trainp2p(delta(:,2),ripple(:,2),[-400/fs -50/fs]);
        
        peakinevent_rd=peakinevent(data.original.ripple,data.original.delta);
        
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).name=data.name;
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).ripple=size(data.original.ripple,1);
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).spindle=size(data.original.spindle,1);
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).delta=size(data.original.delta,1);

        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).train_rd=size(train_rd,1);
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).train_ds=size(train_ds,1);
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).train_dr=size(train_dr,1);
        
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).(type_oi).cooc_rd=size(peakinevent_rd,1);
        res.(exp_gr(exp_var)).(strcat('rat',rat_n)).sleep=sum(diff(data.sleep))/(fs*3600);
        
    end
end


%% plots!
exp_man=1; %experimental manipulation 1=homecage,2=learning,3=retrieval
art=1; %original vs ICA
ev_type=1; %type of event
types={'ripple','spindle','delta','train_rd','train_ds','train_dr','cooc_rd'};
%exp_man=['a','b','c'];

for exp_man=1:3 %homecage vs learning vs retrieval
    t=NaN(rat_nr(end),length(types))
    for ev_type=1:length(types)  %type of event (ripple,spindle,delta and sequences 
            for jj=1:5 %length(rat_nr) % rat number
                t(rat_nr(jj),ev_type)=res.(exp_gr(exp_man)).(strcat('rat',num2str(rat_nr(jj)))).(cell2mat(art_handling(art))).(cell2mat(types(ev_type)));
            end
    end
    t(any(isnan(t),2),:) = [];
% tt is exp_manipulationXrat_nr
    tt(exp_man,:)=mean(t,1);
%tt_tot cointains all the counts. The three fields a, b and c refer to
%homecage, learning and retrieval, respectively. Each section is a 4x10
%matrix. Each row refers to a different animal. The first three columns are
%the counts of ripple, spindle and delta, respectively. The columns 4 to 9
%are the event sequences. Column 10 is the amount of NREM sleep
    tt_tot.(exp_gr(exp_man))=t;
end




close all
figure(1)
subplot(1,2,1)
focus=[1:3];
result=tt(:,focus)';
error_events= [std(tt_tot.a(:,focus));std(tt_tot.b(:,focus));std(tt_tot.c(:,focus))]'/sqrt(size(tt_tot.a,1));
b=bar(result, 'grouped');
hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(result);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',result,error_events,'k','linestyle','none');
hold off
sgtitle(strcat('Events detected'))
legend('homecage','encoding','retrieval')
xticklabels({'ripples','spindles','deltas'})
ylabel('number of events')

subplot(1,2,2)
focus=[4:7];
result=tt(:,focus)';
error_events= [std(tt_tot.a(:,focus));std(tt_tot.b(:,focus));std(tt_tot.c(:,focus))]'/sqrt(size(tt_tot.a,1));
b=bar(result, 'grouped');
hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(result);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',result,error_events,'k','linestyle','none');
hold off

xticklabels({'train rd','train ds','train dr','cooc rd'})
ylabel('number of events')

%% plot with the NREM rates


%create a matrix with the information of the amount of sleep. 'sleep' has n
%rows, where each row is a different animal; each column is a different
%experimental condition (hc,learn,retriev)
types={'ripple','spindle','delta','train_rd','train_rs','train_sd','pinevent_rd','pinevent_rs','pinevent_sd','sleep'};
exp_man=['a','b','c'];
for exp_man=1:3 %homecage vs learning vs retrieval
            for jj=1:3 % rat number
                jjk=jj;
                if jj==3
                    jjk=4;
                end
                sleep(exp_man)=res.(exp_man(exp_man)).(strcat('rat',num2str(jjk))).sleep;
            end
end


figure(2)
subplot(1,2,1)
focus=[1:3];
result=tt(:,focus)'./sleep;
error_events= [std(tt_tot.a(:,focus)./sleep);std(tt_tot.b(:,focus));std(tt_tot.c(:,focus))]'/sqrt(size(tt_tot.a,1));
b=bar(result, 'grouped');
hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(result);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',result,error_events,'k','linestyle','none');
hold off
sgtitle(strcat('Events detected per hour of NREM sleep'))
legend('homecage','encoding','retrieval')
xticklabels({'ripples','spindles','deltas'})
ylabel('number of events')

subplot(1,2,2)
focus=[4:7];
result=tt(:,focus)';
error_events= [std(tt_tot.a(:,focus));std(tt_tot.b(:,focus));std(tt_tot.c(:,focus))]'/sqrt(size(tt_tot.a,1));
b=bar(result, 'grouped');
hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(result);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',result,error_events,'k','linestyle','none');
hold off
xticklabels({'train rd','train ds','train dr','cooc rd'})
ylabel('number of events')


%% save






