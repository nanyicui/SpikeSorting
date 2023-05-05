%% Investigation of negative peaks

close all

%% ARTIFACTS REMOVAL --> da sistemare con nuovi criteri

%% 1 STEP): Investigation on double peaks
% Spikes with multiple local minima are detected. Spikes with more than 2
% local minima in the given time frame are automatically discared (they are less than 1000)
% Then, on spikes with 2 local minima a further criteria are applied; in
% 
% Explanation: 
% 1.	Looping on the whole dataset, for each spike the window starting:ending is selected. Starting and ending are the starting and ending point of the observation window. In particular, they are defined as following:
% 
% DEF_ 
% 
% start= max(acst, negpeak);
% 
% where acst is the last positive value before zero crossing,
% and negpeak is the last positive peak before zero crossing
% 
% start is flagged to 0 in some artifactual cases (starting point of the window occurring after negative peak)
% 
% end= first zero crossing after negative peak. It’s flagged to 46 in some artifactual cases (for instance no values greater than zero found)
% 
% 2.	For each spike, in the given individual window starting:ending, search local minima (time sample+amplitude) and store them in imin, xmin, respectively.
% 
% 3.	Discard local minima greater than 0
% 
% 4.	Store only the corresponding time samples of the local minima in the matrix minima and in the matrix double poly the indexes corresponding to those spikes for which more than one local minima is found.


%% spikes to mark for removal

remove=[];

Spikes=spikes;
%% Window where double minima will be searched
s= stend(:, 14);
e= stend(:, 15);

% Inizialization of results matrices
minima= zeros(size(Spikes, 1), size(Spikes, 2));

deviation1= mean(Spikes,2)+std(Spikes,0,2);

for i= 1: size(Spikes, 1)
    deviation= deviation1(i, 1);
%     % if s(i)==0 this is a case that has to be discared (see code where s(i) was flagged to zero, in IndividualSpikeParameters.m)
%     if s(i)==0
%         continue
%     end
    [xmax, imax, xmin, imin] = extrema(Spikes(i, s(i):e(i)));
    d= find(xmin>0); % I want only the local minima below zero, not potentially local minima exceeding zero
    xmin(d)=[];
    imin(d)=[];
    f= find(xmin<1.5*deviation & xmin>-1.5*deviation);
    xmin(f)=[];
    imin(f)=[];
    minima(i, 1:length(imin))= imin+s(i)-1; % in this way the index is referenced to the zero instead that to the starting point of the searching window
end

% Separation of different number of local minima found:
multiplep= zeros(size(minima, 1), 1);
doublep= zeros(size(minima, 1), 1);
singlep= zeros(size(minima, 1), 1);

for row=1:size(minima, 1)
   if length(find(minima(row, :)>0))>2
       multiplep(row)=row;
   elseif length(find(minima(row, :)>0))==2
       doublep(row)= row; % in doublep I put just the indexes of spikes matrix having more than one minima in the searching window, through these indexes both the indexing of Spikes matrix as well as minima matrix will be possible, as well as s and e and stend
   else
       singlep(row)=row;
   end
end

%% With these indexes you can index minima and therefore Spikes:
multiplep(multiplep==0)=[];
doublep(doublep==0)=[];
singlep(singlep==0)=[];

%plots_multiple_peaks

%% Investigation on the distance between peaks, if distance<5 merge peaks, if distance>5 spike removed (artifactual)
% I take only the first two columns(more relevant)
doubleminima= minima(doublep, 1:2);
doublespikes= Spikes(doublep, :);

%% Validation
s_double= s(doublep, :);
e_double= e(doublep, :);

% figure('name', 'Definition of the double peak area'),subplot(2,2,1), plot(doublespikes(1,:)), hold on, scatter(s_double(1),doublespikes(1,s_double(1)), 'r', 'filled'), hold on, scatter(e_double(1),doublespikes(1,e_double(1)), 'r', 'filled');
% subplot(2,2,2), plot(doublespikes(2,:)), hold on, scatter(s_double(2),doublespikes(2,s_double(2)), 'r', 'filled'), hold on, scatter(e_double(2),doublespikes(2,e_double(2)), 'r', 'filled');
% subplot(2,2,3), plot(doublespikes(3,:)), hold on, scatter(s_double(3),doublespikes(3,s_double(3)), 'r', 'filled'), hold on, scatter(e_double(3),doublespikes(3,e_double(3)), 'r', 'filled');
% subplot(2,2,4), plot(doublespikes(4,:)), hold on, scatter(s_double(4),doublespikes(4,s_double(4)), 'r', 'filled'), hold on, scatter(e_double(4),doublespikes(4,e_double(4)), 'r', 'filled');
% % % saveas( gcf, ['C:\Users\jessica gemignani\Downloads\CURRENT PROJECTS\SPIKES - PERSONAL\images\' filename '_doublepeak.fig'])

distance2= diff(doubleminima');
distance2= distance2';

to_remove_double= find(distance2>5);
to_merge_double= find(distance2<=5);

% with these indexes you can index distance2 therefore doubleminima/doublespikes and doublep


%% CORRECTING MINIMUM VALUES:

Spikes_to_fix = doublep(to_merge_double);

for j= 1:size(Spikes_to_fix, 1)
    m1= Spikes(Spikes_to_fix(j), minima(Spikes_to_fix(j), 1));
    m2= Spikes(Spikes_to_fix(j), minima(Spikes_to_fix(j), 2));
    if m1<m2
        stend(Spikes_to_fix(j), 9)= m1;
    else
        stend(Spikes_to_fix(j), 9)= m2;
    end
end

s_after_fix= stend(Spikes_to_fix, 14);
e_after_fix = stend(Spikes_to_fix, 15);
Spikes_after_fix= Spikes(Spikes_to_fix, :);
min_after_fix= stend(Spikes_to_fix, 9);
imin_after_fix= stend(Spikes_to_fix, 3);

% figure('name', 'Selection of the lowest amplitude peak'),subplot(2,2,1), plot(Spikes_after_fix(1,:)), hold on, scatter(s_after_fix(1),Spikes_after_fix(1,s_after_fix(1)), 'r', 'filled'), hold on, scatter(e_after_fix(1),Spikes_after_fix(1,e_after_fix(1)), 'r', 'filled'), hold on, scatter(imin_after_fix(1), min_after_fix(1), 'g', 'filled');
% subplot(2,2,2), plot(Spikes_after_fix(2,:)), hold on, scatter(s_after_fix(2),Spikes_after_fix(2,s_after_fix(2)), 'r', 'filled'), hold on, scatter(e_after_fix(2),Spikes_after_fix(2,e_after_fix(2)), 'r', 'filled'), scatter(imin_after_fix(2), min_after_fix(2), 'g', 'filled');
% subplot(2,2,3), plot(Spikes_after_fix(3,:)), hold on, scatter(s_after_fix(3),Spikes_after_fix(3,s_after_fix(3)), 'r', 'filled'), hold on, scatter(e_after_fix(3),Spikes_after_fix(3,e_after_fix(3)), 'r', 'filled'),scatter(imin_after_fix(3), min_after_fix(3), 'g', 'filled');
% subplot(2,2,4), plot(Spikes_after_fix(4,:)), hold on, scatter(s_after_fix(4),Spikes_after_fix(4,s_after_fix(4)), 'r', 'filled'), hold on, scatter(e_after_fix(4),Spikes_after_fix(4,e_after_fix(4)), 'r', 'filled'),scatter(imin_after_fix(4), min_after_fix(4), 'g', 'filled');
% % % saveas( gcf, ['C:\Users\jessica gemignani\Downloads\CURRENT PROJECTS\SPIKES - PERSONAL\images\' filename '_doublepeak_lowest.fig'])



%% ARTIFACTS REMOVAL:

Spikes_to_remove= doublep(to_remove_double);

% First I mark the rows with zeros; I do it in this way because if I deleted the rows corresponding to multiplep I would mess up the indexing of rows, so before i just set everything to zero, then I remove the rows corresponding to distant double peaks
% Spikes(multiplep, :)= zeros(size(multiplep, 1),46);
% stend(multiplep, :)= zeros(size(multiplep, 1), 15);
% TimeStamps(multiplep, :) = zeros(size(multiplep, 1), 1);
% 
% Spikes(Spikes_to_remove, :)=zeros(size(Spikes_to_remove, 1),46);
% stend(Spikes_to_remove, :)=zeros(size(Spikes_to_remove, 1),15);
% TimeStamps(Spikes_to_remove, :)=zeros(size(Spikes_to_remove, 1),1);

remove=[remove;Spikes_to_remove;multiplep];

% Removal:
% Spikes(all(Spikes==0,2),:)=[];
% stend(all(stend==0, 2), :)=[];
% TimeStamps(all(TimeStamps==0, 2), :)=[];
% 

%% 2 STEP: negative amplitudes<-500 (~lower threshold LT) or >-25 (~upper threshold UT)

Y = prctile(stend(:, 9),[0.5 99.5]) ;
%Y=[-80000 -5000 80000];

%% or set wanted values here:
LT= Y(1);
UT= Y(2);
%PUT=Y(3);%Positive peak
%%

to_remove_AMPL= find(stend(:, 16)<=LT | stend(:, 9)>= UT );%| stend(:,17)>Y(3));

% % % disp(['filename=' filename ', LT=' num2str(LT) ',UT=' num2str(UT)])
% % % save(['C:\Users\jessica gemignani\Downloads\CURRENT PROJECTS\SPIKES - PERSONAL\images\' filename(1:end-4) '_cutoff_values.mat'], 'LT', 'UT');
%figure('name', 'Distribution of negative peak amplitudes'), hist(stend(:,9), 100), hold on, scatter(LT, 0, 'g', 'filled'), hold on, scatter(UT, 0,'g', 'filled'), title ([ 'Accepted interval based on 5% and 95% percentiles, number of spikes out of the interval=' num2str(size(to_remove_AMPL, 1))]);
% % % saveas(gcf, ['C:\Users\jessica gemignani\Downloads\CURRENT PROJECTS\SPIKES - PERSONAL\images\' filename '_negative_distributions.fig']);

% Spikes(to_remove_AMPL, :)=[];
% stend(to_remove_AMPL, :)=[];
% TimeStamps(to_remove_AMPL, :)=[];

remove=[remove;to_remove_AMPL];

 
%% Full width at half maximum

tot_width= zeros(size(Spikes, 1), 1);
% tot_area= zeros(size(Spikes, 1), 1);

count=0;

for indices= 1: size(Spikes, 1)

    spike= Spikes(indices, :);
    param= stend(indices, :);
    st= param(1, 14);
    en= param(1, 15);
    min= param(1, 9);

    peak1= abs(min-st);
    peak2= abs(min-en);

    p= ((peak1+peak2)./2).*(-1);
    p= p/2;

    u= find(spike(:)>floor(p)-20 & spike(:)<ceil(p)+20);

    i1= find(u>st & u<en);
    
    if isempty(i1)==1
        extr1=st;
        extr2=en;
        count=count+1;
    else
        extr1= u(i1(1));
        extr2= u(i1(end));
    end
           
    width= extr2-extr1;
    tot_width(indices, 1)= width;
end

Y1= prctile(tot_width, [0.5 99.5]);
%figure('name', 'Distribution of FWHM with 5% and 95% percentiles marked'), hist(tot_width, 100), hold on, scatter(Y1, [0 0], 'g', 'filled');
% % % saveas(gcf, ['C:\Users\jessica gemignani\Downloads\CURRENT PROJECTS\SPIKES - PERSONAL\images\' filename '_FWHM_distribution.fig']);

%% Average waveforms in several FWHM intervals

% int1=5;
% int2=10;
% int3=15;
% 
% Spikes1= find(tot_width<=int1);
% Spikes2= find(tot_width>int1 & tot_width<=int2);
% Spikes3= find(tot_width>int2 & tot_width<=int3);
% Spikes4= find(tot_width>int3);
% 
% figure('name', 'Averaged spike for each FWHM interval, with standard deviation bars of the data'), 
% subplot(2,2,1), shadedErrorBar(1:46, mean(Spikes(Spikes1, :)), std(Spikes(Spikes1, :))), title ('0< FWHM <=5 samples');
% subplot(2,2,2), shadedErrorBar(1:46, mean(Spikes(Spikes2, :)), std(Spikes(Spikes2, :))), title ('5< FWHM <=10 samples');
% subplot(2,2,3), shadedErrorBar(1:46, mean(Spikes(Spikes3, :)), std(Spikes(Spikes3, :))), title ('10< FWHM <=15 samples');
% subplot(2,2,4), shadedErrorBar(1:46, mean(Spikes(Spikes4, :)), std(Spikes(Spikes4, :))), title ('FWHM >15 samples (will be discarded)');
% saveas(gcf, ['C:\Users\jessica gemignani\Downloads\CURRENT PROJECTS\SPIKES - PERSONAL\images\' filename(1:end-4) '_average_spike_FWHM.fig']);

%% set the value
% here you can decide the longes FWHM acceptable, based on the showed
% distribution
maxFWHM= 15;

%%

longSpikes= find(tot_width>maxFWHM);
shortSpikes= find(tot_width==0);

long= Spikes(longSpikes,:);
short= Spikes(shortSpikes, :);

%plot_width;

% Only long spikes will be discarded, not the short ones

% Spikes(longSpikes, :)=[];
% stend(longSpikes, :)=[];
% TimeStamps(longSpikes, :)=[];

remove=[remove;longSpikes];

%% Duration of the window

%% set the values
duration_high=20; 
duration_low=5;
%%

dur= stend(:,15)-stend(:,14);
row_to_remove_dur= find(dur>duration_high | dur < duration_low);

% figure('name', 'Distribution of time duration'), hist(dur, 100), hold on, scatter([duration_low duration_high], [0 0], 'g', 'filled');

% Spikes(row_to_remove_dur, :)=[];
% stend(row_to_remove_dur, :)=[];
% TimeStamps(row_to_remove_dur, :)=[];

remove=[remove;row_to_remove_dur];

%% Estimation of the total number of discarded spikes

% due to presence of multiple peaks in the given time frame
n1= size(multiplep, 1) + size(Spikes_to_remove, 1);
% due to negative peaks amplitudes:
n2= size(to_remove_AMPL, 1);
% due to FWHM:
n3= size(longSpikes, 1);
% due to duration of the window:
n4= size(row_to_remove_dur, 1);

% disp(['Percentage of discarded spikes': num2str((n1+n2+n3+n4)*100/size(Spikes,1)) '%']);

%% Clustering on a subset of data

%% Here we extract a subset of spikes having negative peak amplitudes lower than "threshold", in order to perform an extra clustering only on this group and validating the procedure

% threshold= -100;
% 
% to_analyze= find(stend(:,9)<threshold);
% 
% subSpikes= Spikes(to_analyze, :);
% substend= stend(to_analyze, :);
% subTimeStamps= TimeStamps(to_analyze, :);

% this part needs to be finished
%%

% keep Spikes stend TimeStamps filename subSpikes substend subTimeStamps files