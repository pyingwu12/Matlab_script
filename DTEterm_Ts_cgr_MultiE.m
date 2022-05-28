%----------------------------------------------------
% 'time' against 'error' over a specific sub-domain (decided by <xsub> and <ysub>)
%                                        ^^^^^^^^^^^
% Multi experiments; x-axis: time; y-axis: error; color: cloud ratio 
% PY WU @2021/06/13
% 2021/11/23: change critaria to TPW
%----------------------------------------------------


% close all;  
clear;   ccc=':';

saveid=0; % save figure (1) or not (0)
%
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221'};
% expri2={'TWIN001B';'TWIN003B';'TWIN013B'};    
% expnam={ 'FLAT';'V10H10';'V10H05'};
% expmark={'s';'^';'o'};     
% cexp=[ 0.1 0.1 0.1;  0.8 0.1 0.1; 0.1 0.1 0.8];
% cexp=[ 0.1 0.1 0.1;  0.4 0.4 0.4; 0.7 0.7 0.7];
% exptext='exp0313';

% expri1={'TWIN001Pr001qv062221';'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221'};
% expri2={'TWIN001B';'TWIN021B';'TWIN003B';'TWIN020B'};    
% expnam={ 'FLAT';'V05H10';'V10H10';'V20H10'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.55 0.55 0.55;  0.8 0.8 0.8];
% exptext='H1000';

% expri1={'TWIN001Pr001qv062221';'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221'};
% exptext='h750';
% expri2={'TWIN001B';'TWIN025B';'TWIN019B';'TWIN024B'};    
% expnam={ 'FLAT';'V05H075';'V10H075';'V20H075'};
% expmark={'s';'o';'^';'p'};     
% cexp=[ 0.1 0.1 0.1;    0.3 0.3 0.3;  0.5 0.5 0.5;  0.7 0.7 0.7];
% 
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN001B';'TWIN003B'};    
% expnam={ 'FLAT';'TOPO'};
% expmark={'s';'^'};     
% cexp=[ 0.1 0.1 0.1;  0.55 0.55 0.55];
% % cexp=[0,0.447,0.741;  0.85,0.325,0.098]; 
% exptext='FALTOPO';

% expri1={'TWIN003Pr001qv062221'};
% expri2={'TWIN003B'};    
% expnam={ 'TOPO'};
% expmark={'^'};     
% cexp=[ 0.5 0.5 0.5];
% exptext='TOPO';

expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN001Pr0025THM062221';'TWIN003Pr0025THM062221'};   
expri2={'TWIN001B';'TWIN003B';'TWIN001B';'TWIN003B'}; 
expnam={'FLAT';'TOPO';'FLAT_THM25';'TOPO_THM25'};
cexp=[ 0,0.447,0.741; 0.85,0.325,0.098;  0.3,0.745,0.933; 0.929,0.694,0.125]; 
expmark={'s';'^';'s';'^'};     
exptext='THM25';

%--------------------------------
%   subx1=1; subx2=150; suby1=76; suby2=225;
%   xsub=1:150;  ysub=76:225;
  
% expri1={'TWIN030Pr001qv062221';'TWIN031Pr001qv062221';'TWIN033Pr001qv062221'};
% expri2={'TWIN030B';'TWIN031B';'TWIN033B'};    
% expnam={ 'NS5_F';'NS5_T1000';'NS5_T500'};
% expmark={'s';'^';'o'};  
% cexp=[ 0.1 0.1 0.1;  0.4 0.4 0.4;  0.7 0.7 0.7];
% exptext='NS5';
  
% expri1={'TWIN033Pr001qv062221';'TWIN034Pr001qv062221';'TWIN035Pr001qv062221'};
% expri2={'TWIN033B';'TWIN034B';'TWIN035B'};    
% expnam={ 'U05_F';'U05_T1000';'U05_T500'};
% expmark={'s';'^';'o'};  
% cexp=[ 0.1 0.1 0.1;  0.4 0.4 0.4;  0.7 0.7 0.7];
% exptext='U05';
  
% expri1={'TWIN036Pr001qv062221';'TWIN037Pr001qv062221';'TWIN038Pr001qv062221'};
% expri2={'TWIN036B';'TWIN037B';'TWIN038B'};    
% expnam={ 'U15_F';'U15_T1000';'U15_T500'};
% expmark={'s';'^';'o'};  
% cexp=[ 0.1 0.1 0.1;  0.4 0.4 0.4;  0.7 0.7 0.7];
% exptext='U15';

% expri1={'TWIN039Pr001qv062221';'TWIN040Pr001qv062221';'TWIN041Pr001qv062221'};
% expri2={'TWIN039B';'TWIN040B';'TWIN041B'};    
% expnam={ 'U25_F';'U25_T1000';'U25_T500'};
% expmark={'s';'^';'o'};  
% cexp=[ 0.1 0.1 0.1;  0.4 0.4 0.4;  0.7 0.7 0.7];
% exptext='U25';



cloudtpw=0.7; 
%---
stday=22;   sth=21;   lenh=7;  minu=0:10:50;   tint=1;
% stday=22;   sth=23;   lenh=5;  minu=0:10:50;   tint=1;
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
%
nexp=size(expri1,1);  nminu=length(minu);  ntime=lenh*nminu;
%
loadfile=load('colormap/colormap_ncl.mat'); 

ntii=0;
for ei=1:nexp  
  %---decide sub-domain to find max cloud area---
  if contains(expri1{ei},'TWIN001')
      subx1=151; subx2=300; suby1=51; suby2=200;
      xsub=151:300;  ysub=51:200;
  else    
      subx1=1; subx2=150; suby1=51; suby2=200;
      xsub=1:150;  ysub=51:200;
  end       
  nti=0; 
  for ti=1:lenh        
    hr=sth+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
    if ei==1 && mod(ti,tint)==0 
     ntii=ntii+1;    ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end   
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      clear DTE
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3);   
           P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
     hyd  = qr+qc+qg+qs+qi;   
     dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
     tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
     TPW=squeeze(sum(tpw,3)./9.81);     
          
      %---cloud grid ratio and error over sub-domain
      TPW_sub =TPW(xsub,ysub); 
      cgr(nti,ei) = length(TPW_sub(TPW_sub>cloudtpw)) / (size(TPW_sub,1)*size(TPW_sub,2)) *100 ;  
      %---
      if cgr(nti,ei)>0          
        %---find max cloud area in the sub-domain---
        [nx, ny]=size(TPW); 
        rephyd=repmat(TPW,3,3);      
        BW = rephyd > cloudtpw;  
        stats = regionprops('table',BW,'Area','Centroid');     
        centers = stats.Centroid;      
        fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1); 
%         fin=find( centers(:,1)>ny+suby1 & centers(:,1)<ny+suby2+1 & centers(:,2)>nx+subx1 & centers(:,2)<nx+subx2+1);     
        [cgn, ~]=max(stats.Area(fin));   
        max_cldarea(nti,ei) = ((cgn/pi)^0.5)*2;
      end
      
      %---
      [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
      MDTE = DTE.KE + DTE.SH + DTE.LH;            
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----      
      error2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;  
%        MDTE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
              MDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
%        CMDTE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
        CMDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*DTE.KE(:,:,1:end-1),3);     
%        DiKE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
       DiKE_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
      error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
%        DiKE3D_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
       DiKE3D_m(nti,ei)=mean(mean(error2D(xsub,ysub)));
       
      error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
%        DiSH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
       DiSH_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
%        DiLH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
        DiLH_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
      error2D = DTE.Ps;     
%        DiPs_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
        DiPs_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
      
    end % tmi
    disp([s_hr,s_min,' done'])
  end %ti    
  disp([expri2{ei},' done'])
end %ei
%%
%---plot normal curves---
%{
ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};
% for ploti=1:size(ploterms,1)-1
for ploti=[2]

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])
  %---
  hf=figure('position',[100 55 1000 600]);
  for ei=1:nexp
   plot(DiffE_m(:,ei),'LineWidth',6,'color',cexp(ei,:));hold on
  end    
  %----
  set(gca,'yscale','log','fontsize',16,'LineWidth',1.2,'box','on')
  set(gca,'Xlim',[1 ntime-2],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
   set(gca,'Ylim',[1e-4  2e1])
  xlabel('Local time');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')
  %
  s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_hyd',num2str(cloudhyd*1000)];
  if saveid~=0
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
end
%}
%%
%---plot colored curve colored by cloud grid ratio
cmap0=loadfile.colormap_ncl(15:26:end-10,:); 
cmap=cmap0(1:8,:); cmap(1,:)=[0.9 0.9 0.9];
L=[0 0.1 0.5 1 5 10 20];
% L=[0 5 10 20 30 50 70];

% cmap0=loadfile.colormap_ncl(15:22:end,:); cmap=cmap0(1:11,:); cmap(1,:)=[0.9 0.9 0.9];
% L=[0 0.1 0.5 1 3 5 8 12 16 20];

ratio1 = 0;   ratio2 = 0.5;
area1= 1;    area2= 10;

ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};

% for ploti=1:size(ploterms,1)-1
for ploti=[2 4 5 6]

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);    
  set(gca,'position',[0.1300 0.1100 0.71 0.8150])
  
  %---plot colored curves---
  for ei=1:nexp
   plot(1:ntime,DiffE_m(:,ei),'linewidth',12,'color',cexp(ei,:))
   plot_col_line(1:ntime,DiffE_m(:,ei),cgr(:,ei),cmap,L,6)
  end  
  
    %---find 2 points and calculate slope (or quantatitive error)---
%   for ei=1:nexp
%     p1=find(cgr(:,ei)>ratio1,1);   
%     p2=find(cgr(:,ei)>ratio2,1);
    
%     p1=find(max_cldarea(:,ei)>area1,1);   
%     p2=find(max_cldarea(:,ei)>area2,1);   
%     
%     plot(p1,DiffE_m(p1,ei),expmark{ei},'MarkerEdgeColor',cexp(ei,:),'MarkerFaceColor',cexp(ei,:),'MarkerSize',15,'linewidth',2)   
%     plot(p1,DiffE_m(p1,ei),expmark{ei},'MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',15,'linewidth',1)
% 
%     plot(p2,DiffE_m(p2,ei),expmark{ei},'MarkerEdgeColor',cexp(ei,:),'MarkerFaceColor',cexp(ei,:),'MarkerSize',15,'linewidth',2)   
%     plot(p2,DiffE_m(p2,ei),expmark{ei},'MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',15,'linewidth',1) 
    
%     quan_err(ei)= (log10(DiffE_m(p2,ei)) - log10(DiffE_m(p1,ei)) ) ;
%   end   
  
%   for ei=1:nexp      
%       for pi=1:3:ntime-5
%           if max_cldarea(pi,ei)~=0
%             marker_size =10 + max_cldarea(pi,ei) * 20/90;
%             plot(pi,DiffE_m(pi,ei),expmark{ei},'MarkerEdgeColor',cexp(ei,:),'MarkerFaceColor','none','MarkerSize',marker_size,'linewidth',2)   
%             plot(pi,DiffE_m(pi,ei),expmark{ei},'MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',marker_size,'linewidth',1)
%           end
%       end
%   end
% % 
  %----
  set(gca,'yscale','log','fontsize',16,'LineWidth',1.2,'box','on')
  set(gca,'Xlim',[0 ntime-2],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
%    set(gca,'Ylim',[1e-4  2e1])
  xlabel('Local time');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')

%---colorbar---
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.3);
  colormap(cmap); 
  ylabel(hc,'Cloud grid ratio (%)','fontsize',18)  
  set(hc,'position',[0.87 0.160 0.018 0.7150]);

%---legend
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  for ei=1:nexp  
%     plot(xlimit(1)+1.5 , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',15,'MarkerFaceColor',cexp(ei,:),'MarkerEdgeColor',cexp(ei,:),'linewidth',1.5);
%     text(xlimit(1)+1.8 , 10^(log10(ylimit(2))-0.4*ei) ,[expnam{ei},' (',num2str(quan_err(ei)),')'],'fontsize',20,'FontName','Consolas','Interpreter','none','color',cexp(ei,:)); 
    text(xlimit(1)+2.4 , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',20,'FontName','Consolas','Interpreter','none','color',cexp(ei,:)); 
  end
  drawnow  

  s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_hyd',num2str(cloudtpw)];
  if saveid~=0
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
end
%}
%%
% plot dots colored by grid ratio for each time 
%{
cmap0=loadfile.colormap_ncl(15:26:end-10,:); 
cmap=cmap0(1:8,:); cmap(1,:)=[0.9 0.9 0.9];
L=[0 0.1 0.5 1 5 10 20];


ratio1 = 0.01;
ratio2 = 2;
ploterms={'MDTE';'CMDTE';'DiKE';'DiKE3D';'DiSH';'DiLH';'DiPs'};

% for ploti=1:size(ploterms,1)-1
for ploti=[2 ]

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('Position',[100 65 900 600]);    
%   for ei=1:nexp
%     p0=find(cldgr(:,ei)>0,1);
%     plot(1:p0,DiffE_m(1:p0,ei),'color',[0.8 0.9 1],'linewidth',2); hold on
%   end
  set(gca,'position',[0.1300 0.1100 0.71 0.8150])
  
  
  %---plot slope line---
  for ei=1:nexp
    p1=find(cgr(:,ei)>ratio1,1);   
    p2=find(cgr(:,ei)>ratio2,1);
%     line([p1 p2],[DiffE_m(p1,ei) DiffE_m(p2,ei)],'color',cexp(ei,:),'linewidth',3,'Linestyle','-.'); hold on  
    slope(ei)= (log10(DiffE_m(p2,ei)) - log10(DiffE_m(p1,ei)) )/ (p2-p1) ;
  end 

  %
  %---plot points----
  for ei=1:nexp
%     plot_dot(find(cldgr(:,ei)>0,1):ntime,DiffE_m(cldgr(:,ei)>0,ei),cldgr(cldgr(:,ei)>0,ei),cmap,L,expmark{ei},12)
     plot_dot(1:ntime,DiffE_m(:,ei),cgr(:,ei),cmap,L,expmark{ei},12)
  end  
  %---plot black edge---
  for ei=1:nexp    
    p1=find(cgr(:,ei)>ratio1,1);   
    p2=find(cgr(:,ei)>ratio2,1);
    plot(p1,DiffE_m(p1,ei),expmark{ei},'Markeredgecolor','k','Markersize',12)
    plot(p2,DiffE_m(p2,ei),expmark{ei},'Markeredgecolor','k','Markersize',12)
  end
  %
  %----
  set(gca,'yscale','log','fontsize',16,'LineWidth',1.2,'box','on')
  set(gca,'Xlim',[0 ntime-2],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
   set(gca,'Ylim',[1e-4  2e1])
  xlabel('Local time');   ylabel([ploterm,' (J kg^-^1)']);
  title([titnam,'  (',exptext,')'],'fontsize',18,'Interpreter','none')

%---colorbar---
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.3);
  colormap(cmap); 
  ylabel(hc,'Ratio of cloud grids (%)','fontsize',18)    
  set(hc,'position',[0.87 0.160 0.018 0.7150]);

%---legend
  xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
  for ei=1:nexp  
    plot(xlimit(1)+1 , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',cexp(ei,:),'MarkerEdgeColor',cexp(ei,:),'linewidth',1.5);
    text(xlimit(1)+1.8 , 10^(log10(ylimit(2))-0.4*ei) ,[expnam{ei},' (',num2str(slope(ei)),')'],'fontsize',18,'FontName','Consolas','Interpreter','none','color',cexp(ei,:)); 
%  text(xlimit(1)+1.8 , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',18,'FontName','Consolas','Interpreter','none','color',cexp(ei,:)); 
  end
  drawnow  

  s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_hyd',num2str(cloudhyd*1000)];
%   print(hf,'-dpng',[outfile,'.png'])
%   system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end
%}
