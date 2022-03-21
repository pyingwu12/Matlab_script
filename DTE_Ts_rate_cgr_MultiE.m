clear;  ccc=':';
close all

expri1={'TWIN201Pr001qv062221'; 'TWIN003Pr001qv062221'; 'TWIN013Pr001qv062221'; 'TWIN021Pr001qv062221';'TWIN020Pr001qv062221'};   
expri2={'TWIN201B';'TWIN003B';'TWIN013B'; 'TWIN021B'; 'TWIN020B'}; 
exptext='diffTOPO';
expnam={'FLAT';'TOPO';'H500';'V05';'V20'};
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 239 154 183]/255;
xsub0={1:300 ; 1:300; 1:300; 1:300; 1:300}; 
ysub0={1:300; 1:300; 1:300; 1:300; 1:300};

% expri1={'TWIN201Pr001qv062221';'TWIN042Pr001qv062221';'TWIN003Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN042B';'TWIN003B';'TWIN043B'}; 
% exptext='U00';
% expnam={'FLAT';'U00_FLAT';  'TOPO';'U00_TOPO'};
% cexp=[87 198 229; 95 85 147;   242 155 0; 168 63 63]/255; 
% xsub0={1:300 ; 1:300; 1:300; 1:300; 1:300; 1:300}; 
% ysub0={1:300; 1:300; 1:300; 1:300; 1:300; 1:300};

% expri1={'TWIN201Pr001qv062221';'TWIN030Pr001qv062221';'TWIN042Pr001qv062221';'TWIN039Pr001qv062221'};   
% expri2={'TWIN001B';'TWIN030B';'TWIN042B';'TWIN039B'}; 
% exptext='FLAT_U00NS5U25';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';'U25_FLAT'};
% cexp=[87 198 229; 44 125 190; 95 85 147;  24 88 139]/255; 
% xsub0={1:300 ; 1:300; 1:300; 1:300; 1:300; 1:300}; 
% ysub0={1:300; 1:300; 1:300; 1:300; 1:300; 1:300};

% expri1={'TWIN201Pr001qv062221';'TWIN030Pr001qv062221';'TWIN042Pr001qv062221';...
%         'TWIN003Pr001qv062221';'TWIN031Pr001qv062221';'TWIN043Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN030B';'TWIN042B';'TWIN003B'; 'TWIN031B'; 'TWIN043B'}; 
% exptext='U00NS5_thesis';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';  'TOPO';'NS5_TOPO';'U00_TOPO'};
% % % cexp=[87 198 229; 44 125 190; 95 85 147;   242 155 0; 232 66 44; 168 63 63]/255; 
% cexp=[87 198 229; 46 125 195; 99 85 146;   242 155 0; 242 80 50; 163 63 63]/255; 
% xsub0={1:300 ; 1:300; 1:300; 1:300; 1:300; 1:300}; 
% ysub0={1:300; 1:300; 1:300; 1:300; 1:300; 1:300};

% expri1={'TWIN201Pr001qv062221';'TWIN030Pr001qv062221';'TWIN042Pr001qv062221';'TWIN039Pr001qv062221'; ...
%         'TWIN003Pr001qv062221';'TWIN031Pr001qv062221';'TWIN043Pr001qv062221';'TWIN040Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN030B';'TWIN042B';'TWIN039B';  'TWIN003B'; 'TWIN031B';'TWIN043B';'TWIN040B'}; 
% exptext='U00NS5_U25F';
% expnam={'FLAT';'NS5_FLAT';'U00_FLAT';'U25_FLAT';  'TOPO';'NS5_TOPO';'U00_TOPO';'U25_TOPO'};
% cexp=[87 198 229; 44 125 190; 95 85 147; 24 88 139;     242 155 0; 232 66 44; 168 63 63; 117 79 58]/255; 
% xsub0={1:300 ; 1:300; 1:300; 1:300; 1:300; 1:300; 1:300; 1:300}; 
% ysub0={1:300; 1:300; 1:300; 1:300; 1:300; 1:300; 1:300; 1:300};

% expri1={'TWIN201Pr001qv062221';'TWIN042Pr001qv062221'; 'TWIN039Pr001qv062221'};   
% expri2={'TWIN201B';'TWIN042B';'TWIN039B'}; 
% expnam={'FLAT';'U00_FLAT';'U25_FLAT'};
% cexp=[67 141 199; 109 191 230;  20 20 255]/255;
% exptext='U00U25';
% xsub0={1:300 ; 1:300; 1:300; 1:300}; 
% ysub0={1:300; 1:300; 1:300; 1:300};


cloudtpw=0.7; 
%---setting---
plotid='CMDTE'; % "MDTE" or "CMDTE"
stday=22;  sth=21;  lenh=11;  minu=0:10:50;  tint=1;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam=[plotid,' and cloud grid ratio'];   fignam=[plotid,'-slope_Ts_',exptext,'_'];
%-----
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
%---------------------------------------------------
DTE_m=zeros(ntime,nexp);  
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp  
  nti=0;
  xsub=xsub0{ei}; ysub=ysub0{ei}; 
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
      %---
      if exist([indir,'/',expri1{ei}],'dir') && ~exist(infile1,'file') 
        DTE_m(nti,ei)=NaN;
        TPW_m(nti,ei)=NaN;
        continue
      end
      [MDTE, CMDTE]=cal_DTE_2D(infile1,infile2);  
      eval(['DiffE=',plotid,';'])
      DTE_m(nti,ei) = mean(mean(DiffE(xsub,ysub)));  % domain mean of 2D DTE    
      
      
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
     
     TPWsub=TPW(xsub,ysub);
     
     cgr(nti,ei) = length(TPWsub(TPWsub>cloudtpw)) / (size(TPWsub,1)*size(TPWsub,2)) *100 ;
     
     TPW_m(nti,ei)=mean(TPWsub(:));

      if mod(nti,10)==0; disp([s_hr,s_min,' done']); end
    end %minu    
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
DTE_log=log(DTE_m);
DTE_slope = (DTE_log(4:end,:)-DTE_log(1:end-3,:)); 
% DTE_slope = (DTE_log(2:end,:)-DTE_log(1:end-1,:)); 
%%
cexp=[87 198 229; 242 155 0; 146 200 101; 230 70 80; 237 156 187]/255;

%---
close all
% hf=figure('position',[200 45 1000 600]);
hf=figure('position',[200 65 1000 950]);


plotexp=[1 3 4 5 2];
%  plotexp=[1 3 4 2 5];
% plotexp=[3 2 1 6 5 4];
% plotexp=1:nexp;


ax2=subplot('position',[0.12 0.1 0.78 0.625]);
 colororder({'k','k'})
 
yyaxis right
for ei=plotexp
% for ei=[1 3 2 5 4]
   plot(2.5:ntime-1.5,DTE_slope(:,ei),'color',cexp(ei,:),'LineWidth',2.8,'linestyle',':','Marker','none'); hold on
%   plot(1:ntime-1,DTE_slope(:,ei),'color',cexp(ei,:),'LineWidth',2.5,'linestyle',':','Marker','none'); hold on
end
plot([1 ntime-1],[0.01 0.01],'LineWidth',2,'color','k','Marker','none','linestyle','-.')
set(gca,'Ylim',[-1 10],'YTick',[-1 0 1 2 3])
label_h=ylabel('CMDTE growth rate');  label_h.Position(2) = 0.8; label_h.Position(1) = ntime+ntime/17; 
 

yyaxis left
for ei=plotexp
% for ei=[1 3 2 5 4]
  h(ei)=plot(DTE_m(:,ei),'color',cexp(ei,:),'LineWidth',3.8,'linestyle','-','Marker','none'); hold on
end
set(ax2,'Yscale','log','Ylim',[1e-6 1.5e1],'YTick',[1e-4 1e-2 1e0],'fontsize',18,'LineWidth',1.2,'TickDir','out');
ylabel('CMDTE (J kg^-^1)')
% 
% legend(h(plotexp),expnam(plotexp),'Box','off','Interpreter','none','fontsize',25,'Location','east','FontName','Monospaced');
legend(h,expnam,'Box','off','Interpreter','none','fontsize',25,'Location','east','FontName','Monospaced');

set(ax2,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
% 
xlabel('Local time'); 


ax1=subplot('position',[0.12 0.735 0.78 0.2]);
for ei=plotexp
% for ei=[1 3 2 5 4]
  plot(cgr(:,ei),'color',cexp(ei,:),'LineWidth',3.8,'linestyle','-.','Marker','none'); hold on
end
set(ax1,'Yscale','log','Ylim',[2.9e-3 2.2e1],'fontsize',16,'LineWidth',1.2,'TickDir','out'); 
set(ax1,'Xlim',[0 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',[],'YTick',[0.01 0.1 1 10])
ylabel('cloud grid ratio (%)') 

title(ax1,titnam,'fontsize',18,'Position',[floor(ntime/2) 50 0]);

%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/2',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min2'];
print(hf,'-dpng',[outfile,'.png'])
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
