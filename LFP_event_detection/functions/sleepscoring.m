%the function will search for the sleepscoring file and, if does not find
%it, will ask the user to get it. It will then trim the signal leaving only
%the desired sleep stage


function y=sleepscoring(x,trimmed)
    temp=split(trimmed,'.');
    temp=temp(1);
    temp=split(temp,'_');
    temp1=cell2mat(temp(4));
    rat_number=str2num(temp1(4:end));

    l=0;
    l2=0;
    for i=1:7
        if i<=5
            l=length(cell2mat(temp(i)))+l;
        elseif i==6
            l2=length(cell2mat(temp(i)))+l;
        elseif i==7
            l3=length(cell2mat(temp(i)))+l2;
        end
    end
    f1=trimmed(1:l+4);
    f2=trimmed(1:l2+5);
    f3=trimmed(1:l3+6);
    sleep_dir=strcat('/mnt/genzel/Rat/HM/Rat_HM_Ephys/',f1,'/',f2,'/',f3);
    try 
        cd(sleep_dir)
    catch
        sleep_dir=strcat('/mnt/genzel/Rat/HM/Rat_HM_Ephys/',f1,'/',f2);
        cd(sleep_dir)
    dirFiles = dir;
    for i =1:length(dirFiles)
        b=dirFiles(i).name;
        if strfind(b,'eegstates')~=0
                 load(strcat(sleep_dir,'/',b)) 
        end  
    end
    recs_trim=[x,zeros(size(x,2),size(x,1)-600*3600*4)];
    if size(recs_trim,2)>size(recs_trim,1)
        recs_trim=recs_trim';
    end
    if exist('states')
        states_long=reshape(repmat(states,round(length(recs_trim)/length(states)),1),1,[]);
    end
    y=recs_trim(states_long==3,:);
   
end
