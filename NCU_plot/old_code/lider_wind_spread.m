clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat'; cmap=colormap_sprd;

expri='e01';   hr=1:3;  
%----set---- 
vari='U spread';   filenam=[expri,'_U-sprd_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS007/pwin/expri_lider201511/lider_',expri];
L=[1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.4 2.6];
plon=[119.3 122.5]; plat=[21.7 25.5];
lev=19;

ni=0;
for ti=hr
    ni=ni+1;
%---set filename---    
   if ti==24
     s_date='06';   s_hr='00';
   else
     s_date='05';   
     if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end
   end     
   %
   for mi=1:40  
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d02_2015-11-',s_date,'_',s_hr,':00:00'];
     else
       infile=[indir,'/pert',nen,'/wrfout_d02_2015-11-',s_date,'_',s_hr,':00:00'];
     end   
     
     %----read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     varid  =netcdf.inqVarID(ncid,'XLONG');
      lon =netcdf.getVar(ncid,varid);    x=double(lon);
     varid  =netcdf.inqVarID(ncid,'XLAT');
      lat =netcdf.getVar(ncid,varid);     y=double(lat);
     varid  =netcdf.inqVarID(ncid,'U');       us  =(netcdf.getVar(ncid,varid));
     varid  =netcdf.inqVarID(ncid,'V');       vs  =(netcdf.getVar(ncid,varid));    
%---    
     [nx ny]=size(x); nz=size(us,3);   
     u=(us(1:nx,:,:)+us(2:nx+1,:,:)).*0.5;
     %v=(vs(:,1:ny,:)+vs(:,2:ny+1,:)).*0.5;
   
     U(:,mi)=reshape(u(:,:,lev),nx*ny,1); 
     %V(:,mi)=reshape(v(:,:,lev),nx*ny,1); 
   %
     netcdf.close(ncid)
   end %member
   %}
   %uspr(ni)=spread2(U); vspr(ni)=spread2(V); tspr(ni)=spread2(T);
   %
   sprd=spread(U);
   p_sprd=reshape(sprd,nx,ny);
   pmin=min(min(p_sprd));   
   %
%---plot
   if pmin<L(1); L2=[pmin,L]; else L2=L; end
   figure('position',[1800 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,p_sprd,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   %m_coast('color','k');
   %m_gshhs_h('color','k');
   colorbar;   cm=colormap(cmap);   
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z  (lev ',num2str(lev),')'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'.png'];
   %print('-dpng',outfile,'-r350') 
   %}
   %disp([s_hr,' is ok'])
end