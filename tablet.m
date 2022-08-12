%main_spreadsheet 
%it will load the data files that the event detection script produced,
%looping through each one of them, and creates 3 tables, one per event
%type
clear all
close all
clc

% tab=table;
% 
% tab(1,:)=cell2table({'na','na','na','na','na','na','na'});
% tab.Properties.VariableNames = ["Animal","StudyDay","Condition","Trial","Event_Count","Event_Rate","NREM(min)"]

cd C:\Users\Emanuele\Desktop\uni\event %change for directory where the events detected are stored
a=dir;
file_names={
    'Rat_Hm_Ephys_Rat1_389236_20200904','Rat_Hm_Ephys_Rat1_389236_20200909','Rat_Hm_Ephys_Rat1_389236_20200911';
    'Rat_Hm_Ephys_Rat2_389237_20200910','Rat_Hm_Ephys_Rat2_389237_20200915','Rat_Hm_Ephys_Rat2_389237_20200917';
    'Rat_Hm_Ephys_Rat4_389239_20201104','Rat_Hm_Ephys_Rat4_389239_20201109','Rat_Hm_Ephys_Rat4_389239_20201111';
    'Rat_Hm_Ephys_Rat5_406576_20210609','Rat_Hm_Ephys_Rat5_406576_20210612','Rat_Hm_Ephys_Rat5_406576_20210614';
    'Rat_Hm_Ephys_Rat7_406578_20210714','Rat_Hm_Ephys_Rat7_406578_20210720','Rat_Hm_Ephys_Rat7_406578_20210722';
    'Rat_Hm_Ephys_Rat8_406579_20210821','Rat_Hm_Ephys_Rat8_406579_20210803','Rat_Hm_Ephys_Rat8_406579_20210810'
    };
events={'ripple','spindle','delta'};
events_p={'rippleXhr','spindleXhr','deltaXhr'};
animals=[1,2,4,5,7,8];
for focus=2:2
    tab=table;

    tab(1,:)=cell2table({'na','na','na','na','na','na','na'});
    tab.Properties.VariableNames = ["Animal","StudyDay","Condition","Trial",strcat(events(focus),"_Count"),strcat(events(focus),"_Rate"),"NREM(min)"]

    for i=2:length(a)
        if strfind(a(i).name,'presleep')
            load(a(i).name);
            [~,condition]=find(strcmp(file_names,data.name(1:end-9)));
            animal=str2num(a(i).name(17));
            studyday=data.name(end-16:end-9);
            sleep=sum(data.sleepscore==3)/60;
            tab_temp=array2table({animal,studyday,condition,'presleep',size(data.(events{focus}),1),(size(data.(events{focus}),1))/sleep,sleep});
            row=1+(find(animals==animal)-1)*15+(condition-1)*5;
            tab(row,:)=tab_temp;
        end
        if strfind(a(i).name,'postsleep')
            load(a(i).name);
            [~,condition]=find(strcmp(file_names,data.name(1:end-10)));
            animal=str2num(a(i).name(17));
            studyday=data.name(end-16:end-10);
            sleep=sum(data.sleepscore(1:length(data.sleepscore)/4)==3)/60;
            row=2+(find(animals==animal)-1)*15+(condition-1)*5;
            tab_temp=array2table({animal,studyday,condition,'postsleep_1',size(data.(events_p{focus}).('hour1'),2),size(data.(events_p{focus}).('hour1'),2)/sleep,sleep});
            tab(row,:)=tab_temp;
            sleep=sum(data.sleepscore(1+length(data.sleepscore)/4:2*length(data.sleepscore)/4)==3)/60;
            row=3+(find(animals==animal)-1)*15+(condition-1)*5;
            tab_temp=array2table({animal,studyday,condition,'postsleep_2',size(data.(events_p{focus}).('hour2'),2),size(data.(events_p{focus}).('hour2'),2)/sleep,sleep});
            tab(row,:)=tab_temp;
            sleep=sum(data.sleepscore(1+2*length(data.sleepscore)/4:3*length(data.sleepscore)/4)==3)/60;
            row=4+(find(animals==animal)-1)*15+(condition-1)*5;
            tab_temp=array2table({animal,studyday,condition,'postsleep_3',size(data.(events_p{focus}).('hour3'),2),size(data.(events_p{focus}).('hour3'),2)/sleep,sleep});
            tab(row,:)=tab_temp;
            sleep=sum(data.sleepscore(1+3*length(data.sleepscore)/4:4*length(data.sleepscore)/4)==3)/60;
            row=5+(find(animals==animal)-1)*15+(condition-1)*5;
            tab_temp=array2table({animal,studyday,condition,'postsleep_4',size(data.(events_p{focus}).('hour4'),2),size(data.(events_p{focus}).('hour4'),2)/sleep,sleep});
            tab(row,:)=tab_temp;
        end
    end
end
tab