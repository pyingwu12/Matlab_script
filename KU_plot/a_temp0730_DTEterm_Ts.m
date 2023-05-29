%----------------------------------------------------
% 'time' against 'error' over a specific sub-domain (decided by <xsub> and <ysub>)
%                                        ^^^^^^^^^^^
% Multi experiments; x-axis: time; y-axis: error; color: cloud ratio 
% PY WU @2021/06/13
%----------------------------------------------------


close all;  
clear;   ccc=':';
% 
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};
expri2={'TWIN001B';'TWIN003B'};    
expnam={ 'FLAT';'TOPO'};
expmark={'s';'^'};     
cexp=[ 0.1 0.1 0.1;  0.55 0.55 0.55];
exptext='temp0730';



% cloudhyd=0.005;
cloudhyd=0.003;
%---
stday=22;  sth=21;  lenh=8;  minu=0:10:50;  tint=1;
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
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
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
          
      %---cloud grid ratio and error over sub-domain
%       hyd2D_sub =hyd2D(subx1:subx2,suby1:suby2);    
      hyd2D_sub =hyd2D(xsub,ysub); 
      cgr(nti,ei) = length(hyd2D_sub(hyd2D_sub>cloudhyd)) / (size(hyd2D_sub,1)*size(hyd2D_sub,2)) *100 ;      
      %---
      if cgr(nti,ei)>0          
        %---find max cloud area in the sub-domain---
        [nx, ny]=size(hyd2D); 
        rephyd=repmat(hyd2D,3,3);      
        BW = rephyd > cloudhyd;  
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
%       MDTE = DTE.KE + DTE.SH + DTE.LH;            
      CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----      
%       error2D = sum(dPm.*MDTE(:,:,1:end-1),3) + DTE.Ps;  
% %        MDTE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
%               MDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
      error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
%        CMDTE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
        CMDTE_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
       
%       error2D = sum(dPm.*DTE.KE(:,:,1:end-1),3);     
% %        DiKE_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
%        DiKE_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
%        
%       error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
% %        DiKE3D_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
%        DiKE3D_m(nti,ei)=mean(mean(error2D(xsub,ysub)));
%        
%       error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
% %        DiSH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2)));  
%        DiSH_m(nti,ei)=mean(mean(error2D(xsub,ysub)));  
%        
%       error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
% %        DiLH_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
%         DiLH_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
       
      error2D = DTE.Ps;     
%        DiPs_m(nti,ei)=mean(mean(error2D(subx1:subx2,suby1:suby2))); 
        DiPs_m(nti,ei)=mean(mean(error2D(xsub,ysub))); 
      
    end % tmi
    disp([s_hr,s_min,' done'])
  end %ti    
  disp([expri2{ei},' done'])
end %ei
%%
%
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
for ploti=[2]

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])
 
  hf=figure('position',[100 55 1100 600]);
%   hf=figure('Position',[100 65 900 600]);    
  set(gca,'position',[0.1300 0.1100 0.71 0.8150])
  
  %---plot colored curves---
  for ei=1:nexp
   plot(1:ntime,DiffE_m(:,ei),'linewidth',12,'color',cexp(ei,:))
   plot_col_line(1:ntime,DiffE_m(:,ei),cgr(:,ei),cmap,L,6)
  end  
  
% % 
  %----
  set(gca,'yscale','log','fontsize',16,'LineWidth',1.2,'box','on')
  set(gca,'Xlim',[0 ntime-2],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
 set(gca,'Ylim',[2e-4 3e1])
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
    text(xlimit(1)+2.4 , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',20,'FontName','Consolas','Interpreter','none','color',cexp(ei,:)); 
  end
  drawnow  

  s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min_hyd',num2str(cloudhyd*1000)];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);

end
%}
