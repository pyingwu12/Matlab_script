clear;  ccc=':';
% close all
saveid=0; % save figure (1) or not (0)
%---set experiments---
% expri1={'TWIN001Pr001qv062221';'TWIN003Pr001qv062221';'TWIN013Pr001qv062221'};   exptext='exp0103';
% expri2={'TWIN001B';'TWIN003B';'TWIN013B'};
% expnam={'FLAT';'TOPO';'V10H05'};
% cexp=[0.1 0.1 0.1;  0.85,0.325,0.098;  0  0.45 0.74;]; 

expri1={'TWIN001Pr001qv062221';'TWIN001Pr01qv062221';'TWIN003Pr001qv062221';'TWIN003Pr01qv062221'};   
expri2={'TWIN001B';'TWIN001B';'TWIN003B';'TWIN003B'}; 
exptext='qv01';
expnam={'FLAT_qv001';'FLAT_qv01';'TOPO_qv001';'TOPO_qv01'};
cexp=[ 0 0.447 0.741; 0.3 0.745 0.933;  0.85,0.325,0.098; 0.929,0.694,0.125]; 


%---setting---
variplot='QVAPOR';  tit_unit='g/kg';

stday=22;  sth=21;  lenh=13;  minu=0:10:50;  tint=1;  

lev=[]; %[]=all levels, xx:xx for specific levels

plotarea=0;
%
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%---
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
if variplot(1)=='Q'; varinam=lower(variplot(1:2)); else; varinam=lower(variplot);  end
titnam=[variplot,'  RMSD'];   fignam=['RMSD-',varinam,'_',exptext,'_'];

%---set area
% x1=1:150; y1=76:175;    x2=151:300; y2=201:300;  
x1=1:150; y1=51:200;    x2=151:300; y2=51:200;  
xarea=[x1; x2];  yarea=[y1; y2];
arenam={'Whole';'Mount';'Plain'};
linestyl={'--',':'};   markersty={'none','none'};  
%
nexp=size(expri1,1); nminu=length(minu);  ntime=lenh*nminu;
if plotarea~=0; narea=size(xarea,1); else; narea=0; end
%---------------------------------------------------
rmsd_d=zeros(nexp,ntime); if plotarea~=0; rmsd_a=zeros(nexp,ntime,narea); end
ss_hr=cell(length(tint:tint:lenh),1); ntii=0;
for ei=1:nexp
  nti=0;
  for ti=1:lenh    
    hr=sth+ti-1;   hrday=fix(hr/24);  hr=hr-24*hrday;    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    if ei==1 && mod(ti,tint)==0
      ntii=ntii+1;  ss_hr{ntii}=num2str(mod(hr+9,24),'%2.2d');
    end
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      vari =  ncread(infile1,variplot); 
      if isempty(lev); vari1=vari; else; vari1=vari(:,:,lev); end
      if variplot(1)=='Q';   vari1 = double( vari1 )*10^3; end  % for water vapor and hydrometeors
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      vari =  ncread(infile2,variplot); 
      if isempty(lev); vari2=vari; else; vari2=vari(:,:,lev); end
      if variplot(1)=='Q';   vari2 = double( vari2 )*10^3; end  % for water vapor and hydrometeors
      
      %---difference square---
      diff2 = (vari1-vari2).^2;
      %---root mean---
      rmsd_d(ei,nti) =  sqrt( mean(diff2(:)) );   % domain mean
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
  plot(rmsd_d(ei,:),'LineWidth',3,'color',cexp(ei,:)); hold on
  if plotarea~=0
    for ai=1:narea
      plot(rmsd_a(ei,:,ai),'LineWidth',2.5,'color',cexp(ei,:),'linestyle',linestyl{ai},...
        'marker',markersty{ai},'MarkerSize',5,'MarkerFaceColor',cexp(ei,:));
    end
  end
end
legh=legend(expnam,'Box','off','Interpreter','none','fontsize',18,'Location','bestoutside','FontName','Consolas');
%---
set(gca,'Linewidth',1.2,'fontsize',16)
set(gca,'YScale','log')
% set(gca,'Ylim',[3e-3 1.1e0])
set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'XTickLabel',ss_hr)
xlabel('Local time'); ylabel(['RMSD  (',tit_unit,')'])  
if isempty(lev); s_lev='all levels'; else; s_lev=['lev',num2str(lev(1)),'-',num2str(lev(end))]; end
title([titnam,'  (',s_lev,')'],'fontsize',18)
%---
s_sth=num2str(sth,'%2.2d'); s_lenh=num2str(lenh,'%2.2d'); 
outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,'_',s_lenh,'hr_',num2str(nminu),'min'];
if ~isempty(lev);  outfile=[outfile,'_lev',num2str(lev(1),'%.2d'),num2str(lev(end))]; end
if plotarea~=0;  outfile=[outfile,'_',num2str(narea),'area']; end
if saveid==1
print(hf,'-dpng',[outfile,'.png']) 
system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
