close all
clear;  ccc=':';
%---setting
expri='test88';  
%year='2007'; mon='06'; date='01';
year='2018'; mon='06'; s_date='22';  s_hr='05'; minu='00';
infilenam='wrfout';  dom='01'; 

zi=15;  
%indir=['E:/wrfout/expri191009/',expri];
indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];
outdir='/mnt/e/figures/expri191009/';

infile = [indir,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
% qv = ncread(infile,'QVAPOR');
% u = ncread(infile,'U');
% v = ncread(infile,'V');
% w = ncread(infile,'W');
% t = ncread(infile,'T'); t=t+300;
% max(max(t(:,:,zi)))
% min(min(t(:,:,zi)))

% ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
% z=(ph+phb)./9.81; 
%hgt= ncread(infile,'HGT');
% rc = ncread(infile,'RAINC');
% rsh = ncread(infile,'RAINSH');
% rnc = ncread(infile,'RAINNC');
% rain=rc+rsh+rnc;
 tsk = ncread(infile,'TSK');
 hfx = ncread(infile,'HFX');
 qfx = ncread(infile,'QFX'); 
 lhfx = ncread(infile,'LH');
 ust = ncread(infile,'UST');

%
close all
%---plot different variables
%  figure
%    contourf(u(:,:,zi)',20,'linestyle','none')
%    title([expri,' U wind ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar
% 
%  figure
%    contourf(v(:,:,zi)',20,'linestyle','none')
%    title([expri,' V wind ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar
%  figure
%    contourf(w(:,:,zi)',20,'linestyle','none')
%    title([expri,' W wind ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar     
%  figure
%    contourf(qv(:,:,zi)',20,'linestyle','none')
%    title([expri,' qv ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar
%    %caxis([0.015 0.0175])
% figure
%   contourf(t(:,:,zi)',20,'linestyle','none')
%   title([expri,' potential temp  ', s_hr,minu,', zi=',num2str(zi)],'FontSize',15)
%   colorbar  
 % caxis([301.9 302.08])
% figure
%   contourf((z(:,:,zi,ti)+z(:,:,zi+1,ti))*0.5,20,'linestyle','none')
%   title([expri,' geopotential height, ti=',num2str(ti),', zi=',num2str(zi)],'FontSize',15)
%   colorbar  
%  figure('Position',[100 100 600 400])
%    contourf(rain(:,:)',20,'linestyle','none')
%    title([expri,'  rain  ', s_hr,minu,'Z  ,],'FontSize',15)
%    colorbar     
%----
%  figure('Position',[100 100 800 630]);
%    contourf(tsk',20,'linestyle','none')
%    title([expri,' Skin Temp. ', s_hr,minu,'Z'],'FontSize',15)
%    colorbar
%  figure('Position',[100 100 800 630]);
%    contourf(hfx',20,'linestyle','none')
%    title([expri,'  sfc heat flux  ', s_hr,minu,' UTC'],'FontSize',15)
%    colorbar
%  figure('Position',[100 100 800 630]);
%    contourf(qfx'*1000,20,'linestyle','none')
%    title([expri,'  sfc moisture flux  ', s_hr,minu,' UTC'],'FontSize',15)
%    colorbar
%  figure('Position',[100 100 800 630]);
%    contourf(lhfx',20,'linestyle','none')
%    title([expri,'  sfc latent heat flux  ', s_hr,minu,' UTC'],'FontSize',15)
%    colorbar   
 figure('Position',[100 100 800 630]);
   contourf(ust',20,'linestyle','none')
   title([expri,'  sfc latent heat flux  ', s_hr,minu,' UTC'],'FontSize',15)
   colorbar   

%-----profile
%  hf=figure('Position',[100 100 800 500]);  
%    contourf(squeeze(w(:,70,:))',20,'linestyle','none')
%    title([expri,' W wind ', s_hr,minu,'Z '],'FontSize',15)
%    colorbar    
%    %caxis([-2 2])
%    set(gca,'Fontsize',14,'linewidth',1.2)
%    print(hf,'-dpng',[outdir,expri,'_w-prof_',s_hr,minu,'.png']) 

%---HGT---
%  hf=figure('Position',[100 100 800 630]);  
%    contourf(hgt',20,'linestyle','none')
%    %title([expri,'  topography '],'FontSize',16)
%    hc=colorbar; caxis([0 1000])
%    set(hc,'Fontsize',15,'linewidth',1.2);   title(hc,'(m)','Fontsize',15)
%    set(gca,'Fontsize',15,'linewidth',1.2,'TickDir','out')
%    xlabel('km','Fontsize',15); ylabel('km','Fontsize',15)
%    outfile=[outdir,expri,'_topo'];
%    print(hf,'-dpng',[outfile,'.png'])
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);   
%  hf=figure('Position',[100 100 750 500]);  
%    plot(hgt(:,100),'linewidth',2.8,'color',[0.2 0.4 0.1])
%    %title([expri,'  topography '],'FontSize',15)
%    set(gca,'Ylim',[0 1500],'Fontsize',14,'linewidth',1.2)
%    xlabel('(km)','Fontsize',18); ylabel('(m)','Fontsize',18)
%    outfile=[outdir,expri,'_topo-prof'];
%    print(hf,'-dpng',[outfile,'.png'])
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);