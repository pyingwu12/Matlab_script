%-------
%  plot 2-D temperature spread of a height(=plothgt) above surface
%     ***caculate spread before interpolate to the same height level
%     ***use the code which was commented to calculate spread after interpolate (high-cost)
%-------
clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_pbl.mat'; cmap=colormap_pbl;

expri='e02';  hr=0;   plothgt=10;  s_date='26';  s_mon='10';
lev=12;
%----set---- 
vari='Temperature spread';   filenam=[expri,'_Temp-sprd_']; 
outdir=['/work/pwin/plot_cal/lider/'];
indir=['/SAS005/pwin/expri_lider/lider_',expri];
%---
L=[0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.2 1.5 1.7 2];
plon=[119.3 122.5]; plat=[21.7 25.5];
xp=50; yp=86;   %xp=72; yp=131; %(changli)
%
kappa=0.286;   g=9.81;  % kappa=R/cp

%
for ti=hr
%---set filename---    
   if ti<=9; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end  
   for mi=1:40  
     nen=num2str(mi);
     if mi<=9
       infile=[indir,'/pert0',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     else
       infile=[indir,'/pert',nen,'/wrfout_d02_2016-',s_mon,'-',s_date,'_',s_hr,':00:00'];
     end        
     %----read netcdf data--------
     ncid = netcdf.open(infile,'NC_NOWRITE');
     if mi==1;
      varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
      varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
      varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
      [nx ny]=size(x);  
     end
     varid  =netcdf.inqVarID(ncid,'T');        theta=(netcdf.getVar(ncid,varid))+300;
     varid  =netcdf.inqVarID(ncid,'P');        p  =netcdf.getVar(ncid,varid)./100;
     varid  =netcdf.inqVarID(ncid,'PB');       pb =netcdf.getVar(ncid,varid)./100;     
%      varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
%      varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
  %-------  
     P=p+pb;
     T.ori=theta.* ((P./1000).^kappa);   T.ori=T.ori-273;        
     nz=size(theta,3);
     %
%      nz=size(theta,3);
%      P0=double(phb+ph);  PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
%      zg=double(PH)/g;   
%      %---interpolation---
%      %hgt.iso=zeros(nx,ny)+plothgt;  
%      hgt.iso=double(hgt.m)+plothgt;
%      for i=1:nx
%        for j=1:ny
%        X=squeeze(zg(i,j,:));
%        Y=squeeze(T.ori(i,j,:));  var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
%        end
%      end
%      T.ens(:,mi)=reshape(var.iso,nx*ny,1);
     %
     %T(:,mi)=reshape(t(:,:,lev),nx*ny,1);   
     T.ens(:,mi)=reshape(T.ori,nx*ny*nz,1);  
   netcdf.close(ncid)  
   end %member
   %---
   sprd.line=spread(double(T.ens));
%    sprd.resh=reshape(sprd.line,nx,ny);     
   sprd.resh=reshape(sprd.line,nx,ny,nz);  
   %----
   P0=double(phb+ph);  PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;   
   %---interpolation---
   %hgt.iso=zeros(nx,ny)+plothgt;  
   hgt.iso=double(hgt.m)+plothgt;
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(sprd.resh(i,j,:));  var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
     end
   end     

%---plot
%    var.plot=sprd.resh;
   var.plot=var.iso;
   pmin=min(min(var.plot)); if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,var.plot,L2);   set(hp,'linestyle','none');  hold on
   %caxis([L2(1) L(length(L))])  
   cm=colormap(cmap);   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
   %
   %hp=m_plot(x(xp,yp),y(xp,yp),'xk','LineWidth',2,'MarkerSize',9);
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);   
%---
   tit=[expri,'  ',vari,'  ',s_mon,'/',s_date,' ',s_hr,'z  (',num2str(plothgt),'m)'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_date,s_hr,'_',num2str(plothgt),'.png'];
   %print('-dpng',outfile,'-r400')   
end
%}

