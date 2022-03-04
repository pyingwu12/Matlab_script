
clear;  %close all
hr=2; expri='All-03';
%L=[0.5 2 5 8 11 14 17 20 23 26]*0.01;           % A-00z
%L=[-10 -8 -7 -6 -5 -4 -3 -2 -1 -0.5]*0.01;      % A-02z
%L=[-32 -28 -24 -20 -16 -12 -8 -4 -1 -0.5]*0.01; % B-00z
%L=[0.5 1 2 3 4 5 6 7 8 9]*0.01;                 % B-02z
L=[-3 -2.5 -2 -1.5 -1.25 -1 -0.75 -0.5 -0.25 0]*0.01;       % C-02Z

%obs_lon=120.6065;  obs_lat=23.1665; obs_hgt=2679; lev=10;  %A
%obs_lon=120.6967;  obs_lat=23.1746; obs_hgt=1986; lev=7;  %B
obs_lon=120.2925;  obs_lat=23.1467; obs_hgt=285; lev=3;  %C
     
Lt=[100 500 1000 2000 ];
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat';  
%----set---- 
vari='mean U increment';   filenam=[expri,'_incr-u285_'];  type='mean';  
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
%----
yp=160; xp=124;    %xp=124or143
plon=[119 123]; plat=[21.65 25.65];
%cmap=colormap_sprd;
cmap=colormap_sprd([1 3 5 6 7 8 9 11 13 14 15],:); cmap(length(cmap),:)=[225 225 245]/255;
g=9.81;

%----
for ti=hr
%---set filename---    
   if ti==0
     s_date='16';   s_hr='00';
   else
     s_date='16';   s_hr=['0',num2str(ti)];
   end     
   infile1=[indir,'/output/fcstmean_d03_2008-06-',s_date,'_',s_hr,':00:00'];
   infile2=[indir,'/output/analmean_d03_2008-06-',s_date,'_',s_hr,':00:00'];
%----read netcdf data--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');   uf  =(netcdf.getVar(ncid,varid));
   %varid  =netcdf.inqVarID(ncid,'V');   vf  =(netcdf.getVar(ncid,varid)); 
   %
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'U');   ua  =(netcdf.getVar(ncid,varid));
   %varid  =netcdf.inqVarID(ncid,'V');   va  =(netcdf.getVar(ncid,varid)); 
   %
   varid  =netcdf.inqVarID(ncid,'PH');       ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');    hgt =netcdf.getVar(ncid,varid);
   netcdf.close(ncid)
%---   
   [nx ny nz]=size(ph); 
   P0=(phb+ph);   PH=(P0(:,:,1:nz-1)+P0(:,:,2:nz)).*0.5;
   zg=double(PH)./g;
   
   umf=(uf(1:nx,:,:)+uf(2:nx+1,:,:)).*0.5;     %vmf=(vf(:,1:ny,:)+vf(:,2:ny+1,:)).*0.5; 
   uma=(ua(1:nx,:,:)+ua(2:nx+1,:,:)).*0.5;     %vma=(va(:,1:ny,:)+va(:,2:ny+1,:)).*0.5;   
   
   uincr=uma-umf;
   
   for i=1:nx
     for j=1:ny
       X=squeeze(zg(i,j,:));
       Y=squeeze(uincr(i,j,:));
       uincr_alt(i,j)=interp1(X,Y,obs_hgt,'linear');
     end
   end
   
 
%---plot
%
   plotvari=uincr_alt; plotvari(plotvari==0)=NaN;
   pmin=double(min(min(plotvari)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.5],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plotvari,L2);   set(hp,'linestyle','none');  hold on; 
   m_plot(obs_lon,obs_lat,'xk','MarkerSize',10,'LineWidth',2.3)
   %m_line([x(1,yp),x(nx,yp)],[y(1,yp),y(nx,yp)],'LineStyle','--','color','k')
   %m_line([x(xp,1),x(xp,ny)],[y(xp,1),y(xp,ny)],'LineStyle','--','color','k')
   m_grid('fontsize',12);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',1.2);
   ht=m_contour(x,y,hgt,Lt,'color',[0.2 0.2 0.2],'LineWidth',1.2);
   colorbar;   cm=colormap(cmap);  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
     tit=[expri,'  ',vari,' ',s_hr,'z  (height ',num2str(obs_hgt),'m)'];
     title(tit,'fontsize',15)
     outfile=[outdir,filenam,s_hr,'_',type,'.png'];
     print('-dpng',outfile,'-r350')
%}   
end    
%}
%end
