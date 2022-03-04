clear
sth=17;acch=3; expri='MRcycle06'; 


expdir=['/work/pwin/plot_cal/Rain/',expri];
range=8;

%---
nt=0;
for ti=sth
  s_sth=num2str(ti);         % time string
  for ai=acch                % accumulation time
    nt=nt+1;
    %---
    edh=ti+ai;               % end time
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read and add data---
    for j=1:ai
      hr1=num2str(ti+j-1);
      if ti+j==24; hr2='00'; else hr2=num2str(ti+j); end      
      infile=['/work/pwin/data/raingauge_new_1hr_20090808/20090808',hr1,hr2,'_raingauge.dat'];
      A=importdata(infile);  rain(:,j)=A(:,3);
      fin= rain(:,j)<0; rain(fin,j)=0;
    end
    acc=sum(rain,2);
    lat=A(:,1);  lon=A(:,2);    
%---read model data---    
      infile=[expdir,'/acci_',s_sth,s_edh,'.mat'];
      load (infile);        
%--- 
      for mi=1:40          
       [nx ny]=size(xi);
       xi1=reshape(xi,nx*ny,1); yj1=reshape(yj,nx*ny,1); wrfacc1=reshape(acci{mi},nx*ny,1);
       N=length(acc);
       for i=1:N
         dis= sqrt((xi1-lon(i)).^2+(yj1-lat(i)).^2);
         [sdis loc]=sort(dis);     
         d=dis(loc(1:range));   % pick smaller distant
         wa=wrfacc1(loc(1:range));  
         wacci_o(i,mi)=(sum(wa./d))/(sum(1./d));   
       end      
      end
       
      
    n=0;  
    for p=1:N      
        fin=find(isnan(wacci_o(p,:))==0);
        if isempty(fin)==0
          n=n+1;
          [s rank]=sort([acc(p) wacci_o(p,:)]);
          obsrank(n)=find(rank==1);
        end
    end
    
    
    figure('position',[500 100 600 500])
    hist(obsrank,1:41);
    h = findobj(gca,'Type','patch');    set(h,'FaceColor',[0.5 0.6 0.8])
    set(gca,'YTick',[5 10 15 20].*0.01*length(obsrank),'YTickLabel',[5;10;15;20])
    set(gca,'XLim',[0 42])
    set(gca,'YLim',[0 20].*0.01*length(obsrank))
    title(expri,'fontsize',15)
    xlabel('Rank','fontsize',15)
    
    
  
    
  end
end