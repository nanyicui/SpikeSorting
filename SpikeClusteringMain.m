%% main

clear all
close all
path= 'c:\SpikeSorting\';

pathInputFiles=[path,'InputFiles\'];
pathalldata='C:\miceMUA\OutputSpikesWaveForms\';
pathout=[path,'outputParameters\']; 
pathclusters=[path,'outputClusters\']; mkdir(pathclusters)

fidlist=fopen([pathInputFiles,'InputFile2.txt'],'r');

for file=1:8
    
    str=fgetl(fidlist);sp=isspace(str); sp=find(sp==1);
    name2=str(1:sp(1)-1);
    
    for chan=1:64
        
        
        filename=[name2,'-ch',num2str(chan),'-Spikes_TimeStamps'];
        
        filecheck=fopen([pathalldata,filename,'.mat'],'r');
        if filecheck<0 continue; else fclose(filecheck); end
        
        load([pathalldata filename],'Spikes','TimeStamps');

        filename1= [name2,'-ch',num2str(chan),'-parameters'];
        load(strcat(pathout,filename1), 'stend')
        
        stend(stend(:,14)==0,14)=1;
      
        
        %% ARTIFACTS REMOVAL
        % alternatevely, run the code IndividualSpikeParameters.m
        
        %         disp(['Filename=' filename])
        %         disp([ 'Number of initial number of spikes for this file:' num2str(size(Spikes, 1))]);
        IndividualSpikeParameters;
        ArtifactRemovalNew;
        
        ind=1:size(spikes,1);
        ind(remove)=[];
        
        spikes(remove,:)=[];
        index(remove)=[];
        stend(remove,:)=[];        
                    
            %% ANALYSIS
            %% PCA
            k1= 3;   
            [V, pcscores, pcvar] = princomp(spikes(:,5:35));            
            features= pcscores(:, 1:5);            
            %% CLUSTERING         
            clustering
            
            %fileout=[name2,'-ch',num2str(chan),'-CL',num2str(cluster)];
            
            %save([pathclusters fileout],'clusters_index','ind');
           
            %pause
        
        
    end
end