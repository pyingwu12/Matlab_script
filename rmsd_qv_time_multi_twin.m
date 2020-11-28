clear;  ccc=':';
% close all

%---set experiments---
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp13qva1510';
% expri2={'TWIN001B';'TWIN003B'};
% expnam={'FLAT';'TOPO'};
% col=[0,0.447,0.741; 0.85,0.325,0.098]; 

% expri1={'TWIN001Pr001qv062221';'TWIN001Pr001qv062221noMP';'TWIN003Pr001qv062221';'TWIN003Pr001qv062221noMP'};   exptext='noMP';
% expri2={'TWIN001B';'TWIN001B062221noMP';'TWIN003B';'TWIN003B062221noMP'};
% expnam={'FLAT';'FLATnoMP';'TOPO';'TOPOnoMP'};
% col=[0,0.447,0.741; 0.3,0.745,0.933; 0.85,0.325,0.098;  0.929,0.694,0.125]; 

expri1={'TWIN001Pr001qv062221noMP';'TWIN003Pr001qv062221noMP'};   exptext='onlynoMP';
expri2={'TWIN001B062221noMP';'TWIN003B062221noMP'};
expnam={'FLATnoMP';'TOPOnoMP'};
col=[0.3,0.745,0.933;  0.929,0.694,0.125]; 


%---setting---
stday=22;  sth=21;  lenh=20;  minu=[0 20 40];  tint=2;
ylogid=1;  plotarea=1;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam='Qv root mean square difference';   fignam=['QvRMSD_',exptext,'_'];

%---set area
x1=1:150; y1=76:175;    x2=151:300; y2=201:300;  
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'all';'Mon';'Fla'};
linestyl={'--',':'};   markersty={'none','none'};  
%
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
%
%---------------------------------------------------
rmsd_d=zeros(nexp,ntime); if plotarea~=0; rmsd_a=zeros(nexp,ntime,narea); end
ss_hr=cell(length(tint:tint:lenh),1); ntint=0;
for ei=1:nexp
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntint=ntint+1;
      ss_hr{ntint}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      qv1 = double( ncread(infile1,'QVAPOR') )*10^3; 
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      qv2 = double( ncread(infile2,'QVAPOR') )*10^3; 
      %---difference square
      diff2 = (qv1-qv2).^2;
      %---root mean
      rmsd_d(ei,nti) =  sqrt(mean(mean(mean(diff2))));   % domain mean
      if plotarea~=0
        for ai=1:narea
        rmsd_a(ei,nti,ai) = sqrt (mean(mean(mean(  diff2(xarea(ai,:),yarea(ai,:),:) ))) );  % area mean
        end
      end    
    end %tmi
    if mod(ti,5)==0; disp([s_hr,' done']); end
  end
  disp([expri1{ei},' done'])
end
%%
%---set legend---
ni=0;  lgnd=cell(nexp*(narea+1),1);
for ei=1:nexp    
  for ai=0:narea
    ni=ni+1;
    lgnd{ni}=[expnam{ei},'_',arenam{ai+1}];
  end
end
%----
%%
%---plot
hf=figure('position',[100 45 1000 600]);
% hf=figure('position',[100 45 1200 600]);

for ei=1:nexp
  plot(rmsd_d(ei,:),'LineWidth',2.5,'color',col(ei,:)); hold on
  if plotarea~=0
    for ai=1:narea
      plot(rmsd_a(ei,:,ai),'LineWidth',2.2,'color',col(ei,:),'linestyle',linestyl{ai},...
        'marker',markersty{ai},'MarkerSize',5,'MarkerFaceColor',col(ei,:));
    end
  end
end
% legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Monospaced');
legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','se','FontName','Monospaced');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
if ylogid~=0; set(gca,'YScale','log'); end
% set(gca,'Ylim',[4e-3 1e0])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Time(JST)'); ylabel('g/Kg')  
title(titnam,'fontsize',18)
%---
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if ylogid~=0; outfile=[outfile,'_log']; end
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
