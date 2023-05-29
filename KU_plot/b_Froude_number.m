% close all
clear;   ccc=':';
%---setting
expri='TWIN003B';  s_date='22'; hr=23; minu=00;  lev=1;
%----
year='2018'; mon='06'; 
infilenam='wrfout';  dom='01';  grids=1; %grid_spacing(km)
%---
indir=['/mnt/HDD123/pwin/Experiments/expri_twin/',expri]; outdir=['/mnt/e/figures/expri_twin/',expri(1:7)];

titnam='Non-dimensional mountain height';   fignam=[expri,'_FrH_'];

%---
load('colormap/colormap_parula20.mat'); cmap=colormap_parula20;
cmap2=cmap*255; cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[-2 -1 0 1 2 4 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11];
%---
g=9.81;

for ti=hr
  s_hr=num2str(ti,'%2.2d'); 
  for mi=minu   
    %---set filename---
    s_min=num2str(mi,'%2.2d');
    infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
    %------read netcdf data--------
    t = ncread(infile,'T');   t=t+300;   
    ph = ncread(infile,'PH'); phb = ncread(infile,'PHB');
    u.stag = ncread(infile,'U');
    v.stag = ncread(infile,'V');   
    hgt = ncread(infile,'HGT');
    %
    u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
    v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;  
    spd=(u.unstag.^2+v.unstag.^2).^0.5;
    %----   
    PH0=double(phb+ph);    PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   zg=double(PH)/g;      
    [nx, ny, nz]=size(t);
    [y, x]=meshgrid(1:ny,1:nx);
    
 
    N2=g./t(:,:,lev).* (t(:,:,lev+1)-t(:,:,lev))./zg(:,:,lev+1)-zg(:,:,lev);
    Hhat=N2*max(max(hgt))^2./spd(:,:,lev).^2;
    %%
        %---plot---
    plotvar=Hhat';   %plotvar(plotvar<=0)=NaN;
    pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end
    %
    hf=figure('position',[100 45 800 680]);  
    [c, hp]=contourf(plotvar,20,'linestyle','none');
    hold on; contour(hgt',[100 500 900],'color',[0.55 0.55 0.55],'linestyle','--','linewidth',1.8);  
    %
    set(gca,'fontsize',16,'LineWidth',1.2) 
    set(gca,'Xticklabel',get(gca,'Xtick')*grids,'Yticklabel',get(gca,'Ytick')*grids)
    xlabel('(km)'); ylabel('(km)');
    tit={expri,[titnam,'  ',s_hr,s_min,' UTC']}; 
    title(tit,'fontsize',18)

    colorbar;  
%    
    outfile=[outdir,'/',fignam,'d',dom,'_',mon,s_date,'_',s_hr,s_min];
%     print(hf,'-dpng',[outfile,'.png']) 
%     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    

  end
end
