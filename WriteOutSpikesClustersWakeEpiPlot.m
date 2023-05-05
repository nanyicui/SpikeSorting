clear all
close all
path= 'c:\SpikeSorting\';

pathInputFiles=[path,'InputFiles\'];
pathout=[path,'SpikesMerged12h\'];mkdir(pathout)
pathfig=[path,'FiguresClusters\'];mkdir(pathfig)
pathAutoCor=[path,'AutoCorr\'];mkdir(pathout)


fidlist=fopen([pathInputFiles,'InputFile2.txt'],'r');

edges=[0 1 2 4 8 16 32 64 128 256 512 1024 2048];
maxep=10800;

epochl=4;
C = {'b','g','r','c','m'};
E=[];
for file=1:9
    
    
      str=fgetl(fidlist);sp=isspace(str); sp=find(sp==1);
    name2=str(1:sp(1)-1);
    
    for chan=1:64
        
        fileout=[name2,'-ch',num2str(chan),'-TSspikesCL'];
        figname=[name2,'-rem-Channel_',num2str(chan)];

        filecheck=fopen([pathout,fileout,'.mat'],'r');
        if filecheck<0 continue; else fclose(filecheck); end
        
        figure
        
        eval(['load ',pathout,fileout,'.mat str TS SP CL2 CL3 CL4 CL5 -mat']);
                eval(['load ',pathAutoCor,figname,'.mat CCcl -mat']);
pause
        %AMP=max(SP,[],2)-min(SP,[],2);
        AMP=max(SP(:,16:30),[],2)-min(SP(:,8:16),[],2);
        
        for c=1:4
            if c==1 CL=CL2; elseif c==2 CL=CL3;elseif c==3 CL=CL4;elseif c==4 CL=CL5;end
            
            ma=max(CL);
            subplot(4,4,c*4-3)
            for i=1:ma
                cc=find(CL==i);sp=SP(cc,:);mean_spike=mean(sp);std_spike=std(sp);
                shadedErrorBar(1:46, mean_spike, std_spike, {C{i},'markerfacecolor',[1,0.2,0.2],'LineWidth',2}, 1), hold on;
            end
           
            A=[]; FR=[]; H=[];
            for i=1:ma
                cc=find(CL==i);ts=TS(cc); amp1=AMP(cc);
                
                tsh=ts*1000; tsh=diff(tsh);
                h=histc(tsh,edges); H=[H h/sum(h)*100];
                
                ts=ceil(ts/epochl); ts=ts-ts(1)+1;
                
                amp=zeros(1,maxep); fr=zeros(1,maxep);
                for n=1:maxep f=find(ts==n); amp(n)=mean(amp1(f)); fr(n)=length(f); end
               % amp(vs==0)=NaN;fr(vs==0)=NaN;
              
                re=rem(length(amp),15); amp(length(amp)-re+1:end)=[]; amp=nanmean(reshape(amp,15,length(amp)/15));
                re=rem(length(fr),15); fr(length(fr)-re+1:end)=[]; fr=nanmean(reshape(fr,15,length(fr)/15));
                
                A=[A;amp]; FR=[FR;fr];
            end
            
           
            x=1:1:size(A,2); x=x/60;
            
            subplot(4,4,c*4-2)
            plot(x,A,'.-','LineWidth',2)
            axis([0 max(x) 0 max(max(A))*1.3])
            grid on
            
            subplot(4,4,c*4-1)
            plot(x,FR,'.-','LineWidth',2)
            axis([0 max(x) 0 max(max(FR))*1.3])
            
            xt=1:length(edges)
            subplot(4,4,c*4)
            plot(edges,H,'.-','LineWidth',2)
            axis([0 200 0 max(max(H))*1.1])
            %pause
        end
        
        orient landscape
        figname=[name2,'-ch',num2str(chan)];
        saveas(gcf,[pathfig,figname],'tiff')
        %pause
        close all       
    end
end