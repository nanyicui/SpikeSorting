clear all
close all
path= 'c:\SpikeSorting\';

pathInputFiles=[path,'InputFiles\'];
pathout=[path,'AutoCorr\'];mkdir(pathout)
pathin=[path,'SpikesMerged12h\'];mkdir(pathout)
pathfig=[path,'FiguresAutoCorr\'];mkdir(pathfig)
pathvs=['C:\miceMUA\outputVS\'];


fidlist=fopen([pathInputFiles,'InputFile2.txt'],'r');

edges=[0 1 2 4 8 16 32 64 128 256 512 1024 2048];
maxep=10800;

epochl=4;
C = {'b','g','r','c','m'};
E=[];
for file=1:9;
    
    
    str=fgetl(fidlist);sp=isspace(str); sp=find(sp==1);
    name2=str(1:sp(1)-1);
    
    for chan=1:64
        
        fileout=[name2,'-ch',num2str(chan),'-TSspikesCL'];
        
        filecheck=fopen([pathin,fileout,'.mat'],'r');
        if filecheck<0 continue; else fclose(filecheck); end
        
        figure
        
        eval(['load ',pathin,fileout,'.mat str TS SP CL2 CL3 CL4 CL5 -mat']);
        
        fn=name2; fn(fn=='-')='_';
        filevs=[fn,'_fro_VSspec']
        eval(['load ',pathvs,filevs,'.mat w nr r -mat']);
        
        for c=1:4
            if c==1 CL=CL2; elseif c==2 CL=CL3;elseif c==3 CL=CL4;elseif c==4 CL=CL5;end
            
            ma=max(CL);
            CCcl=[];
            for i=1:ma
                cc=find(CL==i);TSvig=TS(cc);
                
                TSEP=ceil(TSvig/epochl); [s1,s2]=ismember(TSEP,w); % change for vig state
                TSvig=TSvig(find(s2));
                TSvig=ceil(TSvig*1000);
                rast=zeros(1,1000*60*60*12);
                rast(TSvig)=1;
                rast=reshape(rast,1000,60*60*12);
                out=find(sum(rast)==0);
                rast(:,out)=[];
                
            
                CC=zeros(size(rast,2),1999);
                for ep=1:size(rast,2);
                    ts=rast(:,ep);
                    [x1,x2]=xcorr(ts,ts,'coeff');
                    x1(1000)=0;
                    CC(ep,:)=x1;
                end
                CCcl=[CCcl;mean(CC)];
                
            end
            
            subplot(2,2,c);
            plot(x2,CCcl,'LineWidth',2);
            axis([-50 50 0 max(max(CCcl))]);
            grid on
            
        end
        
        figname=[name2,'-wake-Channel_',num2str(chan)];
        %change for vig state
        eval(['save ',pathout,figname,'.mat CCcl -mat']);
        saveas(gcf,[pathfig,figname],'fig');

       % save variable CCcl in a mat file, save figure in .fig format (matlab)
%         pause
%         close all
        
    end
end