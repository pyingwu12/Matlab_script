%-------------------------------------------------------
% Caculate integrate qr of a single run (DA cycle & forecasting time or ensemble mean), 
%       plot wind on a constant-height (hgt_w) above surface when wid~=0
%-------------------------------------------------------
%function TPWqr_sing(expri)

clear

hr=0;   minu='00';   expri='e01';   wid=0;   hgt_w=1000; % wind height (m) above surface
%---DA or forecast time---
%infilenam='wrfmean';    type='mean';
%infilenam='wrfout';   type='sing';
infilenam='output/fcstmean';  type=infilenam(8:11); %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];       % path of the experiments
indir=['/SAS009/pwin/expri_largens/',expri];
%indir=['/SAS007/pwin/expri_largens/WRF_shao'];
%indir=['/SAS009/pwin/expri_whatsmore/',expri];  
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];   % path of the figure output
%indir=['/SAS007/pwin/expri_largens/WRF_shao'];  outdir='/SAS011/pwin/201work/plot_cal/largens';
%L=[0.1 0.5 1 1.5 2 3 4 5 6 7 8 10];
L=[0.1 0.5 1 1.5 2 2.5 3 3.5 4 4.5 ];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_qr3.mat';  %cmap(2:13,:)=colormap_qr2([1 3 5 8 9 10 11 13 14 15 16 17],:); cmap(1,:)=[1 1 1];
cmap=colormap_qr3;
%---
varinam='total-qr';    filenam=[expri,'_TPW-qr_'];  
if wid~=0; filenam=[filenam,'wind_']; end
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[117.85 121.8]; plat=[20.5 24.65];

g=9.81;    int=8; %interval for plot wind vector
%
%---
for ti=hr;
   s_hr=num2str(ti,'%2.2d');   % start time string
%---set filename---
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
i%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');   qr  =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
%---integrate TPW---
   P=(pb+p);   [nx ny nz]=size(qr);
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW=sum(tpw,3)./g;
   %TPW=TPW(2:5:end,2:5:end);  x=x(2:5:end,2:5:end);  y=y(2:5:end,2:5:end); 
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
   plotvar=TPW;  plotvar(plotvar<=10e-16)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   %
   figure('position',[100 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [cp hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color','k','LineWidth',0.8);
   cm=colormap(cmap);    caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1) ; 
   %---wind vector--- 
   if wid~=0
   hold on
   qscale = 0.015 ; % scaling factor for all vectors
   h1 = m_quiver(xi,yi,u.plot,v.plot,0,'k') ; % the '0' turns off auto-scaling
   hU = get(h1,'UData');   hV = get(h1,'VData') ;
   set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2); 
   end
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z (',type,')'];   if wid~=0; tit=[tit,' (',num2str(hgt_w/1000),'km wind)']; end
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type];    %print('-dpng',outfile,'-r400') 
   set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
   system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
   system(['rm ',[outfile,'.pdf']]);  
end  %ti
%}
