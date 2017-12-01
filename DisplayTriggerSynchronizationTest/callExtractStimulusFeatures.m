clear all; close all; clc
videoFilename='2017-10-31 15-37-26.avi';
features = extractStimulusFeatures(videoFilename);

figure(1)
subplot(2,1,1)
a1=load('2017-10-20 12-07-05-features-20-Oct-2017.mat');
X1=fft(a1.muFlow);
n1=length(X1);
fbin1=a1.fsVideo*(-n1/2:n1/2-1)/n1;
plot(fbin1,fftshift(abs(X1)))
title('120 hz')
subplot(2,1,2)
a2=load('2017-10-31 15-37-26-features-31-Oct-2017.mat');
X2=fft(a2.muFlow);
n2=length(X2);
fbin2=a2.fsVideo*(-n2/2:n2/2-1)/n2;
plot(fbin2,fftshift(abs(X2)))
title('30 hz')

plot(a1.muFlow)