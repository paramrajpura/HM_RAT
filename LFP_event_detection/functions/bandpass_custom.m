function y= bandpass_custom(x,fs,event)
    tic
    fprintf ('Starting bandpassing')
    fprintf('\n')
    y=zeros(size(x));
    if event==1
        Wn=[100]/(fs/2); %highpass filter frequencies selection. 100 is the cutoff fr., 300 is the niquist fr.
        [d,z] = butter(9,[100 299]/(fs/2));
        sgtitle('Filter profile')
        freqz(d,z,[],fs)
        sgtitle('Filter profile')
    elseif event==2
        Wn=[[9]/(fs/2)]; %highpass filter frequencies selection. 100 is the cutoff fr., 300 is the niquist fr.
        sgtitle('Filter profile')
        [d,z] = butter(9,[9 17]/(fs/2));
        freqz(d,z,[],fs)
    elseif event==3
        Wn=[[0.5]/(fs/2)]; %highpass filter frequencies selection. 100 is the cutoff fr., 300 is the niquist fr.
        sgtitle('Filter profile')
        [d,z] = butter(9,[0.5 4]/(fs/2));
        freqz(d,z,[],fs)
    end
    [b,a] = butter(9,Wn,'high'); %Filter coefficients for LPF.
    
    for i=1:size(x,1)
        y(i,:)=filtfilt(b,a,x(i,:)); 
    end
    if event==1
        fprintf ('Lowpass completed')
       return
    elseif event==2
        Wn=[[17]/(fs/2)]; %lowpass filter frequencies selection. 100 is the cutoff fr., 300 is the niquist fr.
    elseif event==3
        Wn=[[4]/(fs/2)]; %lowpass filter frequencies selection. 100 is the cutoff fr., 300 is the niquist fr.
    end
    clear b a
    [b,a] = butter(9,Wn); %Filter coefficients for LPF.
    fprintf ('Lowpass completed')
    fprintf('\n')
    for i=1:size(x,1)
        y(i,:)=filtfilt(b,a,x(i,:)); 
    end
    toc
  end

   
