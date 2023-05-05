
        Spikes=spikes';
        nsp=size(Spikes,2); % number of spindles
        
        stend= zeros(nsp, 17);
        
        P=zeros(size(Spikes, 2), 2);
        PFWHM= zeros(size(Spikes, 2), 2);
        
        for sp=1:nsp
            actp=Spikes(:,sp);
            
            [minimum, tim_min]= min(actp(8:20));
            [maximum, tim_max]= max(actp(15:30));
            amin=min(actp);
            amax=max(actp([1:5,30:end]));
            if max(actp(1:10))<=0 actp(1)=1; end;
            if max(actp(11:end))<=0 actp(end)=1; end
            
            ac1=find(flipud(actp(1:10))>0); acst=10-ac1(1)+1;
            ac2=find(actp(10:end)>0); acen=10+ac2(1)-1; % end point of negative spike
            peak=find(diff(actp(acen:end))<0);
            [np1,np2]=min(actp(acst:acen));
            negp=np2+acst-1;
            if isempty(peak) peak=46; else peak=acen+peak(1)-1; end
            
            negpeak=find(diff(actp(1:negp))>0);
            if isempty(negpeak) negpeak=1; else negpeak=negpeak(end)+1; end
            
            %% Regression line
            N= size(actp(8+tim_min:15+tim_max), 1);
            
            l= linspace(minimum,maximum, N); %% --> these are the points of the line
            
            values= actp(8+tim_min-1:15+tim_max-1);
            
            values=values';
            
            rmse= sqrt(((l-values).^2)/2);
            
            r= sum(rmse);
            
   %         Definition of the window
            
            start= max(acst, negpeak);
            if start>tim_min
                start=1; % I set a 0 flag in case the starting of the window comes afer the peak because it means it's an artifact/misdetection
            end
            
            signal= actp;
            
            t= find(signal>=0);
            
            if numel(t)~=0
                ending=8+ tim_min+t(1)-1;
            else
                ending=46;
            end
            
            %     % PLOT
            %     plot(actp,'.-b'); hold on
            %     plot([0 46],[0 0],'-k')
            %
            %     axis([0 46 min(actp)*1.1 max(actp)*1.1]); hold on
            %
            
            %     scatter(acst,actp(acst),'or','filled') % start point of negative spike (defined as last positive value before 0 crossing)
            %     scatter(negpeak,actp(negpeak),'om')    % start point of negative spike (defined as last positive peak before 0 crossing)
            %     scatter(negp,actp(negp),'sc','filled') % negative peak
            %     scatter(8+tim_min-1,actp(8+tim_min-1),'sg','filled') % new negative peak
            %     scatter(acen,actp(acen),'dm','filled') % end point of negative spike
            %     scatter(peak,actp(peak),'sm','filled') % first positive peak of afterhyperpolarisation
            %     scatter(15+tim_max-1,actp(15+tim_max-1),'sr','filled') %new positive peak
            %     plot([8+tim_min-1:8+tim_min+N-2],l,'r', 'LineWidth',1.5)
            %     scatter(start, actp(start), 'dk') % start of the window
            %     scatter(ending, actp(ending), 'dk')% end of the window
            % %     scatter(P(sp, 1), -P(sp, 2), 'r', 'filled'),
            % %     scatter(round(PFWHM(sp, 1)), actp(round(PFWHM(sp, 1))), 'y', 'filled'),
            % %     scatter(round(PFWHM(sp, 2)), actp(round(PFWHM(sp, 2))), 'y', 'filled');
            %
            %     legend('spike','0-line','start NEG spike I','start NEG spike II','peak NEG spike','NEW NEG peak','end NEG spike','peak POS spike', 'NEW POS peak', 'fitted line', 'start of the window', 'end of the window')
            %     legend('boxoff')
            %     legend('Location','EastOutside')
            %      title(strcat('RMSE=', num2str(r), ' - Duration of the window=', num2str(ending-start)));
            %
            %     pause
            %     close all %% in this way you can create a graph for each loop cycle and keeping it in pause and then generating another graph and so on GANZO! rifare anche in quello degli spindle
            
            %     stend=[stend; acst negpeak negp acen peak actp(acst) actp(negpeak) actp(negp) actp(acen) actp(peak)]; % save all variables for individual spikes
            
            stend(sp,:)= [acst negpeak negp acen peak actp(acst) actp(negpeak) actp(negp) minimum actp(acen) actp(peak) maximum r start ending amin amax];
            
            %% I set a lower threshold for the positive amplitude equal to 25 microV
            
            %     p = polyfit(t,y,1);
            
            
            
        end
      

