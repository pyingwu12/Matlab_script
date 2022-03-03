%-------------------------------------------------------
% Caculate integrate qv of a single run (DA cycle & forecasting time), 
%       plot wind on a constant-height (hgt_w) above surface when wid~=0
%-------------------------------------------------------
%function TPWqv_sing(expri)
clear all
close all

expri='e01';
hr=2;   minu='00';     wid=0;   hgt_w=1000; % wind height (m) above surface
%---DA or forecast time---
%infilenam='wrfmean';    type='mean';
infilenam='wrfout';    type='sing';
%infilenam='output/fcstmean';  type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];    % path of the experiments
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%indir=['/SAS009/pwin/expri_morakotEC/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/morakot_EC/',expri];
%indir=['/SAS009/pwin/expri_whatsmore/',expri];
%outdir=['/SAS011/pwin/201work/plot_cal/what/',expri];   % path of the figure output
%L=[10 11 12 13 13.5 14 14.5 15 15.5 16];  
L=[30 40 50 55 60 62 64 66 68 70];  
%L=[45 50 55 60 65 70 72 75 80 85 90]; %morakot
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr3.mat';  cmap=colormap_qr3; 
%---
varinam='total qv';    filenam=[expri,'_TPW-qv_'];  
%varinam='qv lev10';    filenam=[expri,'_qv-lev10_'];  
if wid~=0; filenam=[filenam,'wind_']; end
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
g=9.81;    int=8; %interval for plot wind vector
  
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
%---integrate TPW---
   P=(pb+p);   [nx ny nz]=size(qv);
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qv(:,:,2:nz)+qv(:,:,1:nz-1)).*0.5 ) ;    
   %TPW= qv(:,:,10)*1000;    
   TPW=sum(tpw,3)./g;
%---read wind varaibles---------------
   if wid~=0
     varid  =netcdf.inqVarID(ncid,'U');     u.stag =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'V');     v.stag =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'PH');    ph =netcdf.getVar(ncid,varid);
     varid  =netcdf.inqVarID(ncid,'PHB');   phb =netcdf.getVar(ncid,varid); 
     varid  =netcdf.inqVarID(ncid,'HGT');   hgt =netcdf.getVar(ncid,varid); 
       netcdf.close(ncid)
     u.unstag=(u.stag(1:nx,:,:)+u.stag(2:nx+1,:,:)).*0.5;
     v.unstag=(v.stag(:,1:ny,:)+v.stag(:,2:ny+1,:)).*0.5;     
     P0=double(phb+ph);    PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
     zg=double(PH)/g;   
   %---interpolation to constant-height above surface
     hgtiso=double(hgt)+hgt_w;  
     for i=1:nx
       for j=1:ny
       X=squeeze(zg(i,j,:));
       Y=squeeze(u.unstag(i,j,:));     u.iso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       Y=squeeze(v.unstag(i,j,:));     v.iso(i,j)=interp1(X,Y,hgtiso(i,j),'linear');
       end
     end
   %---plot set for vactor
     xi=x(1:int:nx,1:int:ny);             yi=y(1:int:nx,1:int:ny);
     u.plot=u.iso(1:int:nx,1:int:ny,:);   v.plot=v.iso(1:int:nx,1:int:ny,:); 
   end
%---plot---
   plotvar=TPW;  plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   %
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [cp hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)   
   %---wind vector--- 
   if wid~=0
   hold on
   qscale = 0.015 ; % scaling factor for all vectors
   h1 = m_quiver(xi,yi,u.plot,v.plot,0,'k') ; % the '0' turns off auto-scaling
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2); 
   end
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];   if wid~=0; tit=[tit,' (',num2str(hgt_w/1000),'km wind)']; end
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);      

end  %ti
