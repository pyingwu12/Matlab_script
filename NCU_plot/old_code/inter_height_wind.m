clear
hr=17; expri='DA';

%----set---- 
%indir=['/SAS002/pwin/expri_241/morakot_MRcycle04'];
indir=['/SAS002/pwin/expri_241/morakot_newda_1518_vr_900'];  %%%
outdir=['/work/pwin/plot_cal/'];
%----
height=1*10^3;
cmap=colormap_qr;
L=[35 38 42 46 50 54 58 62 66 70 74 78 82 85];
g=9.81;
%----
for ti=hr
   s_hr=num2str(ti);
%---set filename---    
   for mi=1:40
     nen=num2str(mi);
     if mi<=9
      infile=[indir,'/cycle0',nen,'/fcst_d03_2009-08-08_',s_hr,':00:00'];
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_0',nen];
     else
      infile=[indir,'/cycle',nen,'/fcst_d03_2009-08-08_',s_hr,':00:00'];
      %infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00_',nen];
     end

%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');
    lon =netcdf.getVar(ncid,varid);
    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');
    lat =netcdf.getVar(ncid,varid);
    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'U');   u0  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'V');   v0  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'W');   w0  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PH');       ph =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
%---
   [nx ny]=size(lon); nz=size(u0,3);
   u=(u0(1:nx,:,:)+u0(2:nx+1,:,:)).*0.5;
   v=(v0(:,1:ny,:)+v0(:,2:ny+1,:)).*0.5; 
   w=(w0(:,:,1:nz)+w0(:,:,2:nz+1)).*0.5;
   P0=(phb+ph);
   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=PH/g;
%---
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(u(i,j,:));
     U_1km(i,j,mi)=interp1(X,Y,height,'linear');
     Y=squeeze(v(i,j,:));
     V_1km(i,j,mi)=interp1(X,Y,height,'linear');
     Y=squeeze(w(i,j,:));
     W_1km(i,j,mi)=interp1(X,Y,height,'linear');
     end
   end
%---
   netcdf.close(ncid)
   disp(['member ',nen,' OK'])
   end
   save([expri,'_bgrd_wind_1km'],'x','y','U_1km','V_1km','W_1km')
   
   %{
   figure('position',[500 100 600 500])
   m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,Var_1km,16);   set(hp,'linestyle','none');
   m_grid('fontsize',12);
   m_coast('color','k');
   %m_gshhs_h('color','k');
   colorbar;   cm=colormap(jet(16));   
  % hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13)
%---
 %  tit=[expri,'  ',vari,'  ',s_hr,'z  (',type,')'];
  % title(tit,'fontsize',15)
  % outfile=[outdir,filenam,s_hr,'_',type,'.png'];
  % saveas(gca,outfile,'png');  
   %}
end    

