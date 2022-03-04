clear
sth=17:20;acch=1; expri='DA1517vrzh'; ctnid=0;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');    
load '/work/pwin/data/colormap_rain.mat';
cmap=colormap_rain;  clen=length(cmap);
expdir=['/work/pwin/plot_cal/Rain/',expri];
Msize=8;

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
      [wrfacci{1} wrfacci{2} wrfacci{3}]=calPM(acci);          
%--- 
      for mi=1:3          
       wrfacc=wrfacci{mi};
       [nx ny]=size(xi);
       xi1=reshape(xi,nx*ny,1); yj1=reshape(yj,nx*ny,1); wrfacc1=reshape(wrfacc,nx*ny,1);
       N=length(acc);
       for i=1:N
         dis= sqrt((xi1-lon(i)).^2+(yj1-lat(i)).^2);   %!!!!!!isnot real distant !!!!!!!20160302
         [sdis loc]=sort(dis);     
         d=dis(loc(1:8));   % pick smaller distant
         wa=wrfacc1(loc(1:8));  
         wacci_o(i)=(sum(wa./d))/(sum(1./d));    
       end
       [scc(nt,mi) rmse(nt,mi) ETS(nt,mi) bias(nt,mi)]=score(acc(isnan(wacci_o)==0),wacci_o(isnan(wacci_o)==0)',15);
      end
      scc(nt,4)=ti; scc(nt,5)=ai; 
      rmse(nt,4)=ti; rmse(nt,5)=ai; 
      ETS(nt,4)=ti; ETS(nt,5)=ai; 
      bias(nt,4)=ti; bias(nt,5)=ai;       
  end
end



%{
       figure('position',[500 100 600 500])
       m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
       for i=1:length(acc);       
         for k=1:clen-2;
           if (acc(i) > L(k) && acc(i)<=L(k+1))
            c=cmap(k+1,:);
            hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
            set(hp,'linestyle','none');    
           end      
         end
         if acc(i)>L(clen-1)
           c=cmap(clen,:);
           hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
           set(hp,'linestyle','none');   
         end     
         if acc(i)<L(1)
            c=cmap(1,:);
            hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',Msize); hold on
            set(hp,'linestyle','none');   
         end   
       end
       
       colorbar;    cm=colormap(cmap);  hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
       m_grid('fontsize',12);
       %m_gshhs_h('color','k');
       m_coast('color','k');
 %}      
       