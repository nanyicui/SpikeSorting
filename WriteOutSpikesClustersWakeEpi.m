clear all
close all
path= 'c:\SpikeSorting\';

pathInputFiles=[path,'InputFiles\'];
pathalldata='C:\miceMUA\OutputSpikesWaveForms\';
pathparameters=[path,'outputParameters\']; 
pathclusters=[path,'outputClusters\']; mkdir(pathclusters)
pathout=[path,'SpikesMerged12h\'];mkdir(pathout)

fidlist=fopen([pathInputFiles,'InputFile2.txt'],'r');

epochl=4;

for file=1:7
    
    % figure
    
  str=fgetl(fidlist);sp=isspace(str); sp=find(sp==1);
    name2=str(1:sp(1)-1);
%     vvv=str2num(str(sp(2)+1:end));
%     day=vvv(2);
    
    for chan=1:64
        
        filename=[name2,'-ch',num2str(chan),'-Spikes_TimeStamps'];
        
        filecheck=fopen([pathalldata,filename,'.mat'],'r');
        if filecheck<0 continue; else fclose(filecheck); end
        load([pathalldata filename],'Spikes','TimeStamps');
        
        filename1= [name2,'-ch',num2str(chan),'-parameters'];
        load(strcat(pathparameters,filename1), 'stend')
        
        stend(find(stend(:,14)==0),14)=1;
        
        for cluster= 2:5
            
            filein=[name2,'-ch',num2str(chan),'-CL',num2str(cluster)];
            load([pathclusters filein],'clusters_index','ind');
            
            SP=Spikes(ind,:); TS=TimeStamps(ind); 
            
            clusters=zeros(length(ind),1);
            
            for i=1:cluster
                clustind=cell2mat(clusters_index(i,1));
                clusters(clustind)=i;
            end
            
            if cluster==2
                CL2=clusters;
            elseif cluster==3
                CL3=clusters;
            elseif cluster==4
                CL4=clusters;
            elseif cluster==5
                CL5=clusters;
            end
           % pause
        end
        fileout=[name2,'-ch',num2str(chan),'-TSspikesCL'];
        eval(['save ',pathout,fileout,'.mat str TS SP CL2 CL3 CL4 CL5 -mat']);
        
       % pause
    end
end