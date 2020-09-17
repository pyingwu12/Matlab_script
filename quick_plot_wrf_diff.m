%close all
clear;  ccc=':';
%---setting
expri1='TWIN006Pr001THM21';  expri2='TWIN006B';  
year='2018'; mon='06'; s_date='22';  s_hr='10'; minu='00';
infilenam='wrfout';  dom='01'; 

zi=7;  
indir1=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri1];
indir2=['/mnt/HDD008/pwin/Experiments/expri_twin/',expri2];
outdir=['/mnt/e/figures/expri_twin/',expri2(1:7)];


infile1 = [indir1,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];
infile2 = [indir2,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,ccc,minu,ccc,'00'];

 qv1 = ncread(infile1,'QVAPOR');
 qv2 = ncread(infile2,'QVAPOR');
diffqv=qv1-qv2;
% u = ncread(infile,'U');
% v = ncread(infile,'V');
% w = ncread(infile,'W');
% t = ncread(infile,'T'); t=t+300;
% thm = ncread(infile,'THM'); thm=thm+300;
% max(max(t(:,:,zi)))
% min(min(t(:,:,zi)))
% ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
% z=(ph+phb)./9.81; 
%hgt= ncread(infile,'HGT');
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
%

figure('Position',[100 45 800 630])
  contour(diffqv(:,:,zi)',20)
  title([expri1,'  Qv  ', s_hr,minu,', zi=',num2str(zi)],'FontSize',15)
  colorbar  
  caxis([-0.005 0.005])

%-----profile
%  hf=figure('Position',[100 100 800 500]);  
%    contourf(squeeze(w(:,70,:))',20,'linestyle','none')
%    title([expri,' W wind ', s_hr,minu,'Z '],'FontSize',15)
%    colorbar    
%    %caxis([-2 2])
%    set(gca,'Fontsize',14,'linewidth',1.2)
%    print(hf,'-dpng',[outdir,expri,'_w-prof_',s_hr,minu,'.png']) 

