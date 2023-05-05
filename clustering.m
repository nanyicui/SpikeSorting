%% CLUSTERING
% I take the first "number" principal components  and these are my new data

%% validation of the clustering procedure

%% 
% decide here the POTENTIAL number of clusters c to be considered. All the
% variables in the code will be initialized to be able to contain up to c
% matrices corresponding to c clusters. The error is computed until c, then
% the actual number of clusters will be k1, which is decided according to
% some criteria (*** look here)

c= 6;

%%

% err= zeros(1, c);
% for i= 1:c
%     [IDX,C,sumd] = kmeans(features,i);
%     err(1,i)=sum(sumd);
% end
% 
% d= diff(err);
% %sumd= point-to-centroid distances
% 
% %% I set the number of clusters as that one that lower the error under the 5% of the total
% acc_err= d./sum(d);
% ind= find(acc_err<0.05); %(*** selection criterion)
% k1= ind(1);

% figure, plot([1:c], err, 'LineWidth', 1.5), title ('Mean square error'),xlim([ 1 c]),xlabel('Number of clusters'), ylabel('Sum of Squared Error'), hold on, scatter([2:c], -d, 'filled'), legend('SSE', 'Derivative of SSE'), scatter(0, k1, 'r', 'filled'); 
% grid MINOR;
% set(gca,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15] );

%% GENERIC NUMBER OF CLUSTERS

clusters_data= cell(c, 1);
clusters_time= cell(c,1);
clusters_index= cell(c,1);
mean_spike= cell(c, 1);


idx= kmeans(features, k1);

for n=1:k1
    clusters_data{n, 1}= spikes(idx==n, :);
    clusters_time{n, 1}= (index(idx==n))./1000;
    mean_spike{n,1}= mean(clusters_data{n,1});
    clusters_index{n,1}= find(idx==n);
end







