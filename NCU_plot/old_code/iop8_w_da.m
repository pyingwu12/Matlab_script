%function iop8_w_da(hm,expri,plothgt)

%--------------------------------------------------------------------------
% plot 2-D (ensemble mean) wind divergence
%--------------------------------------------------------------------------

clear;  
hm='00:00';   expri='true';  plothgt=5000;  %lev=4; 

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';   cmap=colormap_br;
%cmap=colormap_br2([3 4 5 7 8 9 11 13 14 15 17 18 19],:);
%----set---- 
vari='W';   filenam=[expri,'_w_'];   
%
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
s_date='16';
dom='03';
num=size(hm,1);
dx=3000; dy=3000;
%---
%plon=[118.8 122.8]; plat=[21.5 25.65];
plon=[118.35 121.65]; plat=[21.3 24.85];
L=[-4 -3 -2.0 -1.0 -.5  -0.1  0.1  0.5 1 2 3 4];

%----
for ti=1:num;
   time=hm(ti,:);
%---set filename---=============================
   if strcmp(expri,'true')==1
   infile=['/SAS007/pwin/expri_sz6414/true/wrfout_d',dom,'_2008-06-',s_date,'_',time,':00']; 
   else       
   infile=[indir,'/output/fcstmean_d',dom,'_2008-06-',s_date,'_',time,':00'];
   end
%---read netcdf data and calculate the variable--------
   ncid  = netcdf.open(infile ,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid);               
   varid =netcdf.inqVarID(ncid,'W');   wstag =netcdf.getVar(ncid,varid);
   netcdf.close(ncid); 
   %--------------------
   [nx ny]=size(lon); nz=size(ph,3)-1;    
   wunstag=wstag(:,:,1:nz)-wstag(:,:,2:nz+1);
  %-----------------
    g=9.81;
    P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
    zg=double(PH)/g;   
  %---interpolation to 1km-height
    hgt.iso=zeros(size(hgt.m))+plothgt;  
    %hgt.iso=double(hgt.m)+plothgt;  
    for i=1:nx
      for j=1:ny
      X=squeeze(zg(i,j,:));
      Y=squeeze(wunstag(i,j,:));     variso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
      end
    end
%------plot---=================================
   plotvar=variso;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on; 
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   %
   hold on;    m_contour(x,y,hgt.m,[plothgt plothgt],'k--')
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   %
   tit=[expri,'  ',vari,'  ',time(1:2),time(4:5),'z  (',num2str(plothgt/1000),'km)'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(plothgt/1000),'km.png'];
   %print('-dpng',outfile,'-r400')       
end