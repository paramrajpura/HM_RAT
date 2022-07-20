function artefact=resetting_artefact(x)
    fs=600;
    timest=[1:1:size(x,2)];
    win=1:2000*fs;
    deriv=diff(diff(x));
    thresh=2*std(deriv);
    detect=deriv>=thresh;
    pos=diff(detect)==1;
    select=find(pos);
    distance=abs([select, 0,0]-[0,0, select]);
    reset=select(distance>=6*fs & distance<=14*fs);
    artefact=zeros(size(timest));
    for i=1:length(reset)
        artefact(find(timest==reset(i)))=1;
    end
end