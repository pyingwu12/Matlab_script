function iop8_qr_sing(hm,expri,vari,plothgt)
%clear
%hm=['00:00';'00:30';'01:00';'01:30';'02:00';'03:00';'04:00';'05:00';'06:00'];   
%hm=['00:00'];   
%expri='vr124';  vari='QRAIN';  plothgt=7000; %lev=6;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr2.mat';  cmap=colormap_qr2([1 3 5 8 9 10 13 14 15 16],:);

%----set---- 
varit=vari;   filenam=[expri,'_',vari,'_']; 
indir=['/SAS007/pwin/expri_sz6414/',expri];
outdir=['/work/pwin/plot_cal/IOP8/',expri,'/'];
%date=16;
s_date='16';  num=size(hm,1);
%----
L=[0.02 0.05 0.1 0.2 0.3 0.4 0.7 1 1.5];
%plon=[117.5 123]; plat=[20.5 25.8];
plon=[118.35 121.65]; plat=[21.3 24.85];
%----
for ti=1:num
   time=hm(ti,:);
%---set filename---
   %hrday=fix(ti0/24);  ti=ti0-24*hrday;  s_date=num2str(date+hrday);    %%%
   %if ti<10;  s_hr=['0',num2str(ti)];  else  s_hr=num2str(ti);  end   %%%      
   %infile=[indir,'/wrfout_d03_2008-06-',s_date,'_',time,':00'];   
   infile=[indir,'/output/fcstmean_d03_2008-06-',s_date,'_',time,':00'];   
%----read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,vari);       qx  =double(netcdf.getVar(ncid,varid))*1000;
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt.m =netcdf.getVar(ncid,varid); 
   %-----------------
   var.a=qx;
   [nx ny nz]=size(qx);
   g=9.81;
   P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   zg=double(PH)/g;   
   
   %---read wind varaibles--------------------
   varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
    netcdf.close(ncid)
   u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
   v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;     
   
   %---interpolation to 1km-height
   hgt.iso=zeros(size(hgt.m))+plothgt;  
   %hgt.iso=double(hgt.m)+plothgt; 
   for i=1:nx
     for j=1:ny
     X=squeeze(zg(i,j,:));
     Y=squeeze(u.unstag(i,j,:));     u.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');  %%
     Y=squeeze(v.unstag(i,j,:));     v.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');  %%
     %
     Y=squeeze(var.a(i,j,:));     var.iso(i,j)=interp1(X,Y,hgt.iso(i,j),'linear');
     end
   end
%---plot set for vactor
   int=6;
   xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
   u.plot=u.iso(1:int:nx,1:int:ny,:);   v.plot=v.iso(1:int:nx,1:int:ny,:); 
   
%---plot---
   plot.var=var.iso;   plot.var(plot.var==0)=NaN;
   %plot.var=var.a(:,:,lev);  plot.var(plot.var==0)=NaN;
   pmin=double(min(min(plot.var)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   %m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plot.var,L2);   set(hp,'linestyle','none');
   cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)
   %
   hold on;    m_contour(x,y,hgt.m,[plothgt plothgt],'k--')
   %---wind vector---   
   qscale = 0.015 ; % scaling factor for all vectors
   h1 = m_quiver(xi,yi,u.plot,v.plot,0,'k') ; % the '0' turns off auto-scaling
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2); 
   %---
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1); 
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color','k','LineWidth',0.8);     
   %
   tit=[expri,'  ',varit,'  ',time(1:2),time(4:5),'z  (',num2str(plothgt/1000),'km)'];
   title(tit,'fontsize',15,'FontWeight','bold')
   outfile=[outdir,filenam,time(1:2),time(4:5),'_',num2str(plothgt/1000),'km.png'];
   print('-dpng',outfile,'-r400')
  %}
%---    

end 
