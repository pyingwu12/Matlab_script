close all
clear
%---setting
expri='ens10';  nen='03';
year='2018'; mon='06'; s_date='21';  s_hr='21'; minu='10'; 
dirmem='pert'; infilenam='wrfout';  dom='01'; 

% zi=9;   yi=100;
indir=['/mnt/HDD003/pwin/Experiments/expri_ens200323/',expri];
outdir='/mnt/e/figures/ens200323';

infile = [indir,'/',dirmem,nen,'/',infilenam,'_d01_',year,'-',mon,'-',s_date,'_',s_hr,':',minu,':00'];
qv = ncread(infile,'QVAPOR');
u = ncread(infile,'U');
v = ncread(infile,'V');
w = ncread(infile,'W');
t = ncread(infile,'T'); t=t+300;


% p = ncread(infile,'P'); pb = ncread(infile,'PB');
% Rcp=287.43/1005;  
% P=p+pb;
% T0=t.*(100000./P).^(-Rcp); %temperature
% 
% tsk = ncread(infile,'TSK');

% ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
% z=(ph+phb)./9.81; 
%  hgt= ncread(infile,'HGT');
% rc = ncread(infile,'RAINC');
% rsh = ncread(infile,'RAINSH');
% rnc = ncread(infile,'RAINNC');
% rain=rc+rsh+rnc;

%%

%---plot different variables
%  figure
%    contourf(u(:,:,zi)',20,'linestyle','none')
%    title([expri,' mem',nen,' U wind ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar
%  figure
%    contourf(v(:,:,zi)',20,'linestyle','none')
%    title([expri,' mem',nen,' V wind ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar
%  figure
%    contourf(w(:,:,zi)',20,'linestyle','none')
%    title([expri,' mem',nen,'  W wind  ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar     
%  figure
%    contourf(qv(:,:,zi)',20,'linestyle','none')
%    title([expri,' mem',nen,' qv ', s_hr,minu,'Z , zi=',num2str(zi)],'FontSize',15)
%    colorbar
%    %caxis([0.015 0.0175])
% figure
%   contourf(t(:,:,zi)',20,'linestyle','none')
%   title([expri,' mem',nen,' potential temp  ', s_hr,minu,', zi=',num2str(zi)],'FontSize',15)
%   colorbar  
  %caxis([299 299.55])
% figure
%   contourf((z(:,:,zi,ti)+z(:,:,zi+1,ti))*0.5,20,'linestyle','none')
%   title([expri,' mem',nen,' geopotential height, ti=',num2str(ti),', zi=',num2str(zi)],'FontSize',15)
%   colorbar  
%  figure('Position',[100 100 600 400])
%    contourf(rain(:,:)',20,'linestyle','none')
%    title([expri,' mem',nen,'  rain  ', s_hr,minu,'Z  , zi=',num2str(zi)],'FontSize',15)
%    colorbar
%    
%  figure    
%    contourf(squeeze(w(:,yi,:))',20,'linestyle','none')
%    title([expri,' mem',nen,' W wind ', s_hr,minu,'Z '],'FontSize',15)
%    colorbar    
% 
%  figure    
%    contourf(squeeze(T0(:,yi,:))',20,'linestyle','none')
%    title([expri,' mem',nen,' Potential Temp. ', s_hr,minu,'Z '],'FontSize',15)
%    colorbar

%  figure
%    contourf(tsk',20,'linestyle','none')
%    title([expri,' Skin Temp. ', s_hr,minu,'Z'],'FontSize',15)
%    colorbar
% 
%  hf=figure('Position',[100 100 800 630]);  
%    contourf(hgt',20,'linestyle','none')
%    %title([expri,'  topography '],'FontSize',16)
%    hc=colorbar; caxis([0 3000])
%    set(hc,'Fontsize',15,'linewidth',1.2);   title(hc,'(m)','Fontsize',15)
%    set(gca,'Fontsize',15,'linewidth',1.2,'TickDir','out')
%    xlabel('km','Fontsize',15); ylabel('km','Fontsize',15)
%    outfile=[outdir,'/',expri,'_topo'];
%    print(hf,'-dpng',[outfile,'.png'])
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
% %    
%  hf=figure('Position',[100 100 750 500]);  
%    plot(hgt(:,100),'linewidth',2.8,'color',[0.2 0.4 0.1])
%    %title([expri,'  topography '],'FontSize',15)
%    set(gca,'Ylim',[0 3000],'Fontsize',14,'linewidth',1.2)
%    xlabel('(km)','Fontsize',18); ylabel('(m)','Fontsize',18)
%    outfile=[outdir,'/',expri,'_topo-prof'];
%    print(hf,'-dpng',[outfile,'.png'])
%    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%    
