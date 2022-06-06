function plot_compare_eventdetect(x,x_bp,det_manual,det_auto)

distance=20;
close all
figure(1)
ax(1)=figure(1);
plot([0:length(x)-1]/600,7*zscore(x))
hold on
plot([0:length(x)-1]/600,2*zscore(x_bp)+distance)
xlabel("Seconds")

zoom=0.003;
win=6;
center=win/2;
fs=600;
axis([center-win/2 center+win/2 -std(x)*zoom-40 std(x_bp)+distance/2])

i=1;
plot([det_auto(i),det_auto(i)],[-50 120],"--","color","black")
plot([det_manual(i),det_manual(i)],[-50 120],"--","color","blue")

for i=1:length(det_auto)
plot([det_auto(i),det_auto(i)],[-50 120],"--","color","black")
end
for i=1:length(det_manual)
plot([det_manual(i),det_manual(i)],[-50 120],"--","color","blue")
end
legend('original signal','bandpassed signal','automatic detection','manual detection')

% sum(det_auto<=normal_ripples(end)+10)
% for i=1:sum(ripple_peak<=normal_ripples(end)+10)
%     plot([ripple_peak(i),ripple_peak(i)],[-50 120],"--","color","black")
% end
% axis([100 112 -30 90])
% title("Original data")
% 
% 
% ax(2)=figure(2);
% plot([0:length(cleaned(14,1:300*600))-1]/600,7*zscore(cleaned(14,1:300*600)))
% hold on
% plot([0:length(cleaned(14,1:300*600))-1]/600,2*zscore(cleaned_bp(14,1:300*600))+60)
% xlabel("Seconds")
% det_auto=[4.4,10.6,11.35,31.5,32.25,35.75,37.1,39.4,64.2,108.4,123.1,155.25,156.5,160.8,209,239.7,244.4];
% normal_ripples=[10.25,34.7,40.75,65.4,69,87.6,96.2,125.2,135.6,142.25,149.6,159.9,161.3,161.7,213.3,244.9,249.7];
% 
% for i=1:length(det_auto)
% plot([det_auto(i),det_auto(i)],[-50 120],"--","color","red")
% end
% 
% for i=1:length(normal_ripples)
% plot([normal_ripples(i),normal_ripples(i)],[-50 120],"--","color","blue")
% end
% sum(ripple_peak<=normal_ripples(end)+10)
% for i=1:sum(ripple_peak<=normal_ripples(end)+10)
%     plot([ripple_peak(i),ripple_peak(i)],[-50 120],"--","color","black")
% end
% axis([100 112 -30 90])
% title("Filtered data")
end