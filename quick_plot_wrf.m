 %close all
 clear;  ccc=':';
%---setting
expri='TWIN013B';  
%year='2007'; mon='06'; date='01';
year='2018'; mon='06'; s_date='22';  s_hr='21'; minu='00';
infilenam='wrfout';  dom='01'; 

zi=10;  
%indir=['E:/wrfout/expri191009/',expri];
% indir=['/mnt/HDD003/pwin/Experiments/expri_test/',expri];  outdir='/mnt/e/figures/expri191009';
indir=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];
% indir=['/mnt/HDD016/pwin/Experiments/expri_test201002/',expri]; outdir=['/mnt/e/figures/expri_test201002/'];


infile = [indir,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
% qv = ncread(infile,'QVAPOR');
% u = ncread(infile,'U');
% v = ncread(infile,'V');
 %w = ncread(infile,'W');
% t = ncread(infile,'T'); t=t+300;
% thm = ncread(infile,'THM'); thm=thm+300;
% max(max(t(:,:,zi)))
% min(min(t(:,:,zi)))
% ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
% z=(ph+phb)./9.81; 
hgt= ncread(infile,'HGT');
% rc = ncread(infile,'RAINC');
% rsh = ncread(infile,'RAINSH');
% rnc = ncread(infile,'RAINNC');
% rain=rc+rsh+rnc;
%  tsk = ncread(infile,'TSK');
%  hfx = ncread(infile,'HFX');
%  qfx = ncread(infile,'QFX'); 
%  lhfx = ncread(infile,'LH');
%  ust = ncread(infile,'UST');
%%
epsilon=0.622;
Rd=287.04; % Specific gas constant
cvd=719;   % specific heat capacity at constant volume
cpd=Rd+cvd;  % Isobaric specific heat
%
p = ncread(infile,'P');        pb = ncread(infile,'PB');   
qv = ncread(infile,'QVAPOR');     
t = ncread(infile,'T');    t=t+300;
P  = double(p+pb); 

ev=qv./(epsilon+qv) .* P/100; 
T  = t.*(1e5./P).^(-Rd/cpd);
esw = 6.11*exp(53.49-6808./T-5.09*log(T));

RH=ev./esw*100;

 figure('Position',[100 100 800 650]);
   contourf(RH(:,:,1)',20,'linestyle','none')
   caxis([70 100])
   hold on
   contour(hgt',[100 500 900],'color',[0.6 0.6 0.6],'linewidth',2,'linestyle','--')
   title([expri,' RH ', s_hr,minu,'UTC'],'FontSize',15)
   colorbar
%%
% close all
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
% figure('Position',[100 100 800 630])
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
% figure('Position',[100 45 800 630])
%   contourf(thm(:,:,zi)',20,'linestyle','none')
%   title([expri,' potential temp  ', s_hr,minu,', zi=',num2str(zi)],'FontSize',15)
%   colorbar  

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
%  figure('Position',[100 100 800 630]);
%    contourf(ust',20,'linestyle','none')
%    title([expri,'  sfc latent heat flux  ', s_hr,minu,' UTC'],'FontSize',15)
%    colorbar   

%-----profile
%  hf=figure('Position',[100 100 800 500]);  
%    contourf(squeeze(w(:,70,:))',20,'linestyle','none')
%    title([expri,' W wind ', s_hr,minu,'Z '],'FontSize',15)
%    colorbar    
%    %caxis([-2 2])
%    set(gca,'Fontsize',14,'linewidth',1.2)
%    print(hf,'-dpng',[outdir,expri,'_w-prof_',s_hr,minu,'.png']) 

%---HGT---
%  hf=figure('Position',[100 100 800 650]);  
%    contour(hgt',20,'LineWidth',1.5)
%    %title([expri,'  topography '],'FontSize',16)
%    hc=colorbar; caxis([0 1000])
%    set(hc,'Fontsize',16,'linewidth',1.4);   title(hc,'(m)','Fontsize',16)
%    set(gca,'Fontsize',16,'linewidth',1.4)
%    xlabel('km'); ylabel('km')
%    outfile=[outdir,'/',expri,'_topo'];
% %    print(hf,'-dpng',[outfile,'.png'])
% %    system(['convert -trim ',outfile,'.png ',outfile,'.png']);   
%  hf=figure('Position',[100 100 900 600]);  
%    plot(hgt(:,100),'linewidth',2.8,'color',[0.85,0.325,0.098])
%    %title([expri,'  topography '],'FontSize',15)
%    set(gca,'Ylim',[0 1500],'Fontsize',16,'linewidth',1.4)
%    xlabel('km'); ylabel('height (m)')
%    outfile=[outdir,'/',expri,'_topo-prof'];
% %    print(hf,'-dpng',[outfile,'.png'])
% %    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
