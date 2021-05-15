clear;  ccc=':';
close all

%---experiments
expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221'};   exptext='exp13nozh';
expri2={'TWIN001B';'TWIN003B'};
expnam={'FLAT';'TOPO'};
col=[  0,0.447,0.741; 0.85,0.325,0.098; ]; 

%---setting---
stday=22;  sth=21;  lenh=20;  minu=[00 20 40];  tint=2;
% stday=21;  sth=15;  lenh=48;  minu=00;  tint=3;
ylogid=1;  plotarea=1;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD008/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam='moist DTE (no Zh)';   fignam=['2DMoDTE_',exptext,'_'];

%---set area
x1=1:150; y1=76:175;    x2=151:300; y2=201:300;  
%x1=1:150; y1=51:200;    x2=151:300; y2=[1:50, 201:300];  
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'all';'Mon';'Fla'};
linestyl={'--',':'};   markersty={'none','none'};  
%
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
%
%---------------------------------------------------
DTE_dm_nozh=zeros(nexp,ntime); 
if plotarea~=0; DTE_am_nozh=zeros(nexp,ntime,narea); end
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
      nti=nti+1;   s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      zh_max1=cal_zh_cmpo(infile1,'WSM6');  
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      zh_max2=cal_zh_cmpo(infile2,'WSM6');  
      %---
      moMDTE=cal_DTEmo_2D(infile1,infile2);
      %
      moMDTE_nozh=moMDTE(zh_max1<1 & zh_max2<1); %size(moMDTE_nozh)
      DTE_dm_nozh(ei,nti) = mean(mean(moMDTE_nozh));  % domain mean of 2D DTE      
      if plotarea~=0  % area mean of 2D DTE
        for ai=1:narea
          moDTE_area = moMDTE(xarea(ai,:),yarea(ai,:)); 
          moDTE_area_nozh= moDTE_area( zh_max1(xarea(ai,:),yarea(ai,:))<1 & zh_max2(xarea(ai,:),yarea(ai,:))<1 );     
          %size(moDTE_area_nozh)
          DTE_am_nozh(ei,nti,ai)=mean(mean( moDTE_area_nozh ));
        end
      end      
    end %minu
    if mod(ti,5)==0; disp([s_hr,' done']); end
  end %ti
  disp([expri1{ei},' done'])
end % expri
%%
%---set legend---
ni=0;  lgnd=cell(nexp*(narea+1),1);
for ei=1:nexp    
  for ai=0:narea
    ni=ni+1;
    lgnd{ni}=[expnam{ei},'_',arenam{ai+1}];
  end
end
%%
%---plot
hf=figure('position',[100 45 1000 600]);
for ei=1:nexp
  plot(DTE_dm_nozh(ei,:),'LineWidth',2.5,'color',col(ei,:)); hold on
  if plotarea~=0
    for ai=1:narea
      plot(DTE_am_nozh(ei,:,ai),'LineWidth',2.2,'color',col(ei,:),'linestyle',linestyl{ai},...
        'marker',markersty{ai},'MarkerSize',5,'MarkerFaceColor',col(ei,:));
    end
  end
end
legh=legend(lgnd,'Box','off','Interpreter','none','fontsize',18,'Location','se','FontName','Monospaced');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
if ylogid~=0; set(gca,'YScale','log'); end 
% set(gca,'Ylim',[5e-4 1e1])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Time(JST)'); ylabel('DTE (JKg^-^1)')  
title(titnam,'fontsize',18)
%---
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(sth),'_',num2str(lenh),'hr_',num2str(nminu),'min'];
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if ylogid~=0; outfile=[outfile,'_log']; end
% print(hf,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
