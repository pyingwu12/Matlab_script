clear; 
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_pbl.mat'; cmap=colormap_pbl;

expri='e02';   hr=0;  s_date='26';
%----set---- 
vari='10m-wind spread';    filenam=[expri,'_wind10-sprd_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
L=[0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.2 1.5 1.7 2];
plon=[119.3 122.5]; plat=[21.7 25.5];
lev=12;  %xp=72; yp=131;
xp=50; yp=86;

ni=0;
for ti=hr
    ni=ni+1;
%---set filename---    
  if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end  
   %
   for mi=1:40  
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d02_2016-10-',s_date,'_',s_hr,':00:00'];
     else
       infile=[indir,'/pert',nen,'/wrfout_d02_2016-10-',s_date,'_',s_hr,':00:00'];
     end        
     %----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   if mi==1;
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'PH');      ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');     phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');     hgt.m =netcdf.getVar(ncid,varid); 
   [nx ny]=size(x);  nz=size(ph,3)-1; 
   end
   varid  =netcdf.inqVarID(ncid,'U');       u.stag  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'V');       v.stag  =(netcdf.getVar(ncid,varid));
   %--
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;       
   sp.ori=(u.unstag.^2+v.unstag.^2).^0.5;  
   %
   sp.ens(:,mi)=reshape(sp.ori,nx*ny*nz,1);    
%---
   netcdf.close(ncid)
   end %member
   %
   sprd.line=spread(double(sp.ens));
   sprd.resh=reshape(sprd.line,nx,ny,nz); 
   %----
   g=9.81;  
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;  
   %-
   hgt.iso=double(hgt.m)+10; 
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(sprd.resh(i,j,:));  var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
     end
   end    
   %
%---plot---
   plot.var=var.iso;   plot.var(plot.var==0)=NaN;
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plot.var,L2);   set(hp,'linestyle','none');  hold on
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);   
   cm=colormap(cmap);    hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   %hp=m_plot(x(xp,yp),y(xp,yp),'xk','LineWidth',2,'MarkerSize',9);
%---
   tit=[expri,'  ',vari,'  ',s_date,'-',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_date,s_hr,'.png'];
   print('-dpng',outfile,'-r400')   
   %}
   %disp([s_hr,' is ok'])
end
%}

