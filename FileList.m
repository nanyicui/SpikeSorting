clear all
close all
path= 'c:\SpikeSorting\';

pathInputFiles=[path,'InputFiles\'];
pathdata=[path,'data\'];
pathalldata='C:\miceMUA\OutputSpikesWaveForms\';
pathout=[path,'SpikesMerged12h\']; mkdir(pathout)
pathfig=[path,'FiguresClusters\'];mkdir(pathfig)

pathparameters=[path,'outputParameters\'];
pathclusters=[path,'outputClusters\'];

fidlist=fopen([pathInputFiles,'InputFile1.txt'],'r');

E=[]; A=[];
for file=1:17
    
    
    str=fgetl(fidlist);sp=isspace(str); sp=find(sp==1);
    name2=str(1:sp(1)-1);
    name2(3)='-';
    vvv=str2num(str(sp(1)+1:end));
    day=1;
    
    
%             str=fgetl(fidlist);sp=isspace(str); sp=find(sp==1);
%         name2=str(sp(1)+1:sp(2)-1);
%         name2(3)='-';
%         vvv=str2num(str(sp(2)+1:end));
%         day=vvv(2);
    
    for chan=1:64
        
        fileout=[name2,'-ch',num2str(chan),'-TSspikesCL'];
        
        filecheck=fopen([pathout,fileout,'.mat'],'r');
        if filecheck<0 continue; else fclose(filecheck); end
        
        E=[E; file vvv(1) day chan]
        A=[A;name2(1:2)]
        
    end
end


    
