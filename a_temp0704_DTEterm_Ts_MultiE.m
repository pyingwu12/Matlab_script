clear;  ccc=':';
close all
saveid=1;

% expri1={'TWIN201Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221';
%         'TWIN001Pr0025THM062221';'TWIN003Pr0025THM062221';'TWIN013Pr0025THM062221'};   
% expri2={'TWIN201B';'TWIN003B';'TWIN013B';'TWIN001B';'TWIN003B';'TWIN013B'}; exptext='THM25';
% expnam={'FLAT';'TOPO';'H500';'FLAT_THM25';'TOPO_THM25';'H500_THM25'};
% % % cexp=[87 198 229; 242 155 0; 146 200 101;  19 71 117; 140 83 60; 111 127 66]/255; 
% cexp=[87 198 229; 242 155 0; 146 200 101;  28 88 119; 171 106 105; 125 127 55]/255; 
% linexp={'-';'-';'-';':';':';':'};


% expri1={'TWIN201Pr001qv062221';'TWIN030Pr001qv062221';'TWIN042Pr001qv062221';...
%         'TWIN003Pr001qv062221';'TWIN031Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN030B';'TWIN042B';'TWIN003B'; 'TWIN031B'; 'TWIN043B'}; 
% exptext='U00NS5';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';  'TOPO';'NS5_TOPO';'U00_TOPO'};
% cexp=[87 198 229; 24 126 218; 75 70 154;     242 155 0; 242 80 50; 155 55 55]/255; 
% linexp={'-';'-';'-';'-';'-';'-'};

expri1={'TWIN201Pr001qv062221';'TWIN042Pr001qv062221';...
        'TWIN003Pr001qv062221';'TWIN043Pr001qv062221'};   
expri2={'TWIN201B';'TWIN042B';'TWIN003B'; 'TWIN043B'}; 
exptext='U00';
% expnam={'FLAT';'U00_FLAT';  'TOPO';'U00_TOPO'};
expnam={'ORI_H00V00';'U00_H00V00';  'ORI_H00V00';'U00_H10V10'};
cexp=[87 198 229;  75 70 154;     242 155 0;  155 55 55]/255; 
linexp={'-';'-';'-';'-';'-';'-'};


cloudtpw=0.7; 
%---setting---
stday=22;  sth=21;  lenh=11;  minu=0:10:50;  tint=1;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin/JAS_R1';
% titnam=[plotid,' and cloud grid ratio'];   fignam=[plotid,'-slope_Ts_',exptext,'_'];
%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
%---------------------------------------------------

ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp  
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1;     ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      
      
     qr = double(ncread(infile2,'QRAIN'));   
     qc = double(ncread(infile2,'QCLOUD'));
     qg = double(ncread(infile2,'QGRAUP'));  
     qs = double(ncread(infile2,'QSNOW'));
     qi = double(ncread(infile2,'QICE')); 
     
     P=double(ncread(infile2,'P')+ncread(infile2,'PB')); 
  
     hyd  = qr+qc+qg+qs+qi;   
     dP=P(:,:,1:end-1,:)-P(:,:,2:end,:);
     tpw= dP.*( (hyd(:,:,2:end,:)+hyd(:,:,1:end-1,:)).*0.5 ) ;
     TPW=squeeze(sum(tpw,3)./9.81);     
     cgr(nti,ei) = length(TPW(TPW>cloudtpw)) / (size(TPW,1)*size(TPW,2)) *100 ; 
     
     
     %---
     [DTE, P]=cal_DTEterms(infile1,infile2);               
         dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
         dPall = P.f2(:,:,end)-P.f2(:,:,1);
         dPm = dP./repmat(dPall,1,1,size(dP,3));       
     CMDTE = DTE.KE3D + DTE.SH + DTE.LH;   
      %----    
     error2D = sum(dPm.*CMDTE(:,:,1:end-1),3) + DTE.Ps;
       CMDTE_m(nti,ei)=mean(error2D(:));  
       
      error2D = sum(dPm.*DTE.KE3D(:,:,1:end-1),3);     
       DiKE3D_m(nti,ei)=mean(error2D(:)); 
       
      error2D = sum(dPm.*DTE.SH(:,:,1:end-1),3);     
       DiSH_m(nti,ei)=mean(error2D(:));  
       
      error2D = sum(dPm.*DTE.LH(:,:,1:end-1),3);     
        DiLH_m(nti,ei)=mean(error2D(:));       


      if mod(nti,10)==0; disp([s_hr,s_min,' done']); end
    end %minu    
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---plot colored curve colored by cloud grid ratio
load('colormap/colormap_ncl.mat')
cmap=colormap_ncl(6:30:end-30,:); cmap(1,:)=[0.9 0.9 0.9];  cmap(8,:)=[0.75 0.1 0];
L=[0 0.01 0.1 0.5 1 5 10];

close all

ploterms={'CMDTE';'DiKE3D';'DiSH';'DiLH'};
for ploti=1:4

  ploterm=ploterms{ploti}; titnam=ploterm;  fignam=[ploterm,'_',exptext,'_'];
  eval(['DiffE_m=',ploterm,'_m;'])

  hf=figure('position',[100 55 1000 650]);
  set(gca,'position',[0.1300 0.1200 0.71 0.81])

  plotexp=1:nexp;
%   plotexp=[1 4 3 6 2 5];
  for ei=plotexp
    h(ei)= plot(DiffE_m(:,ei),linexp{ei},'LineWidth',4.5,'color',cexp(ei,:),'Markersize',10); hold on
  end

  for ei=1:nexp
    plot_col_line(1:ntime,ones(1,ntime)*10^(-6.3+0.3*ei),cgr(:,ei),cmap,L,7)
  end  

  legh=legend(h(plotexp),expnam{plotexp},'Box','off','Interpreter','none','fontsize',25,'Location','se','FontName','Monospaced');
  set(legh,'Position',[0.5773 0.3278 0.2520 0.3008])


%---colorbar---
  L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
  hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',16,'LineWidth',1.3);
  colormap(cmap); 
  ylabel(hc,'Cloud grid ratio (%)','fontsize',18)  
  set(hc,'position',[0.87 0.160 0.018 0.7150]);

%---
  set(gca,'Linewidth',1.2,'fontsize',20)
  set(gca,'YScale','log');  %
  set(gca,'Ylim',[5e-7 2e1],'YTick',[1e-4 1e-2 1e0])
  set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
  xlabel('Local time'); ylabel('J kg^-^1')  
  title([titnam,' evolution'],'fontsize',23)
%---
  s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];

  if saveid==1
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

end
