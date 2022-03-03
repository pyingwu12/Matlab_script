clear
%close all

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_sprd.mat';  cmap=colormap_sprd;

outdir='/work/pwin/plot_cal/IOP8/localization/';
vari='R localization weighting';   filenam='localization';  

C=0;        vclr=4000; 

 radp=4; swp=1.4;  angp=103; disp=23;  lev=6;  point=6;
 O=importdata('/SAS004/pwin/data/obs_sz6414/obs_d03_2008-06-16_00:00:00');
 fin=find(O(:,1)==radp & O(:,2)==swp & O(:,3)==angp & O(:,4)==disp);
 obs_lon=O(fin,5);  obs_lat=O(fin,6); obs_hgt=O(fin,7);

earthradius=6.37122e6;  g=9.81;
zhgt=[10,50,100:100:12000]';
%---

infile='/SAS009/pwin/expri_cctmorakot/shao_sing/wrfout_d01_2009-08-09_00:00:00';
ncid = netcdf.open(infile,'NC_NOWRITE');     
 varid  =netcdf.inqVarID(ncid,'XLONG');  lonm =netcdf.getVar(ncid,varid);   xd01=double(lonm);
 varid  =netcdf.inqVarID(ncid,'XLAT');   latm =netcdf.getVar(ncid,varid);   yd01=double(latm); 
 varid  =netcdf.inqVarID(ncid,'HGT');    hgtd01 =double(netcdf.getVar(ncid,varid));

%----
infile='/SAS007/pwin/expri_sz6414/vr128/cycle01/fcst_d03_2008-06-16_02:00:00';
ncid = netcdf.open(infile,'NC_NOWRITE');     
 varid  =netcdf.inqVarID(ncid,'XLONG');  lonm =netcdf.getVar(ncid,varid);   x=double(lonm);
 varid  =netcdf.inqVarID(ncid,'XLAT');   latm =netcdf.getVar(ncid,varid);   y=double(latm); 

 varid  =netcdf.inqVarID(ncid,'LANDMASK');    land =netcdf.getVar(ncid,varid);
 varid  =netcdf.inqVarID(ncid,'PH');     ph =netcdf.getVar(ncid,varid);
 varid  =netcdf.inqVarID(ncid,'PHB');    phb =netcdf.getVar(ncid,varid); 
 truelat1 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT1')); 
 truelat2 =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'TRUELAT2'));
 cen_lon =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LON'));
 cen_lat =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CEN_LAT'));
 
 %varid  =netcdf.inqVarID(ncid,'HGT');    hgt =netcdf.getVar(ncid,varid);
 hgt=griddata(xd01,yd01,hgtd01,x,y,'cubic');
 hgt(hgt<0)=0;
 
%---Lambort---
lat1 =truelat1*pi/180; lat2=truelat2*pi/180;  lon0=cen_lon*pi/180;   lat0=cen_lat*pi/180;
n=double(log( cos(lat1)/cos(lat2) ) / log( tan(0.25*pi+0.5*lat2)/tan(0.25*pi+0.5*lat1) ));
f=cos(lat1)*tan(0.25*pi+0.5*lat1)^n/n;
rh0=f/tan(0.25*pi+0.5*lat0)^n;
%
rh=f./tan(0.25*pi+0.5*y*pi./180).^n;
xL=rh.*sin(n*(x*pi./180-lon0))*earthradius;
yL=(rh0-rh.*cos(n*(x*pi./180-lon0)))*earthradius;
%
rh=f/tan(0.25*pi+0.5*obs_lat*pi/180)^n;
obs_lonL=rh*sin(n*(obs_lon*pi/180-lon0))*earthradius;
obs_latL=(rh0-rh*cos(n*(obs_lon*pi/180-lon0)))*earthradius;
%---
[nx ny nz]=size(ph); 
P0=(phb+ph);   PH=(P0(:,:,1:nz-1)+P0(:,:,2:nz)).*0.5;
zg=double(PH)./g;

%hclr=zeros(nx,ny);  hclr(land==0)=108000;  hclr(land==1)=108000; 
hclr=108000;
for i=1:nz-1; x3(:,:,i)=xL; y3(:,:,i)=yL; hgt3(:,:,i)=hgt;   end

hdis=sqrt( (y3-obs_latL).^2  + (x3-obs_lonL).^2);
vdis=abs(zg-obs_hgt);
max_hgt=max(max(hgt));
R=sqrt( exp(   (hdis./(hclr/3).*exp(hgt3./max_hgt*C) ).^2 + ( vdis./(vclr/3) ).^2  ) );
R1=1./R;


%------plot-------
L=0:0.1:1;  L2=0.1:0.1:0.9;

plotvar=R1(:,:,lev);
figure('position',[600 500 600 500])
m_proj('Lambert','lon',[119 123],'lat',[21.65 25.65],'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
Lt=[100 500 1000 2000 ];
ht=m_contour(x,y,double(hgt),Lt,'color',[0.6 0.6 0.6],'LineWidth',1.2); 
hold on

[c hp]=m_contour(x,y,plotvar,'linewidth',1.5);   set(hp,'linewidth',1.5);  
colorbar;   caxis([L(1) L(length(L))]) 
%colorbar('YLim',[0 1],'YTick',L,'YTickLabel',L,'YGrid','on');

%m_plot(obs_lon,obs_lat,'xk','MarkerSize',10,'LineWidth',2.3)
%m_text(121.8,21.8,['c=',num2str(C),', Rd=',num2str(hclr/1000)],'fontsize',14)

m_grid('fontsize',12);
%m_coast('color','k');
%m_gshhs_h('color','k','LineWidth',1);      
tit=[vari,' (inverse)  lev',num2str(lev)];
title(tit,'fontsize',15)
outfile=[outdir,filenam,'_',num2str(C),'_lev',num2str(lev),'_p',num2str(point),'.png'];
% print('-dpng',outfile,'-r350')
%%
%-----plot profile---============================
%---difine lon and lat for profile---
dis= ( (y-obs_lat).^2 + (x-obs_lon).^2 );
[mid mxI]=min(dis);
[dmin yp]=min(mid);
xp=mxI(yp); 
%---interpolation---
for i=1:nx
   X=squeeze(zg(i,yp,:));
   Y=squeeze(R1(i,yp,:));
   R1_prof(:,i)=interp1(X,Y,zhgt,'linear');
end  
plotvar=R1_prof;
[xi zi]=meshgrid(x(:,yp),zhgt);
%
figure('position',[200 500 700 500])
[c hp]=contour(xi,zi,plotvar,L2,'linewidth',1.5);    hold on
colorbar;   caxis([L(1) L(length(L))]) 
colorbar('YLim',[0 1],'YTick',L,'YTickLabel',L,'YGrid','on');
 
plot(obs_lon,obs_hgt,'xk','MarkerSize',10,'LineWidth',2.3)
plot(x(:,yp),hgt(:,yp),'k','LineWidth',1.3);
text(122,500,['c=',num2str(C),', Rd=',num2str(hclr/1000)],'fontsize',14)
set(gca,'XLim',[119 123],'fontsize',13)
xlabel('longitude'); ylabel('height(m)')

tit=[vari,' (inverse)  ',num2str(mean(y(:,yp))),'°N '];
title(tit,'fontsize',15)
outfile=[outdir,filenam,'-prof_',num2str(C),'_',num2str(hclr/1000),'_p',num2str(point),'.png'];
% %print('-dpng',outfile,'-r350')  
% 
% 
% 
%  %{
% hight=1:max_hgt;
% fa0=exp(hight/max_hgt*0);
% fa1=exp(hight/max_hgt*1);
% fa08=exp(hight/max_hgt*0.8);
% fa05=exp(hight/max_hgt*0.5);
% fa03=exp(hight/max_hgt*0.3);
% fa_1=exp(hight/max_hgt*-1);
% 
% figure('position',[200 100 700 500])
% hp=plot(hight,fa1,hight,fa08,hight,fa05,hight,fa03,hight,fa0,hight,fa_1);  set(hp,'LineWidth',2)
% 
% hl=legend('c=1','c=0.8','c=0.5','c=0.3','c=0','c=-1'); set(hl,'fontsize',13,'Position',[0.18 0.7 0.15 0.1])
% xlabel('hight(m)','fontsize',16); 
% title('Multiplied factor','fontsize',15)
% print('-dpng',[outdir,'c-factor'],'-r350')  
% 
% %}
% 
% 
%%
dis=0:36000; dis2=0; C=1.5;  hclr=36000;
Rtest=sqrt( exp(  (dis./(hclr/3).*exp(0./max_hgt*C) ).^2 + (dis2/(vclr/3))^2  )  ) ;
Rtest2=sqrt( exp(  (dis./(hclr/3).*exp(3000./max_hgt*C) ).^2 + (dis2/(vclr/3))^2  )  ) ;
%Rtest=sqrt( exp( (dis/(hclr/3).*( exp(3000./max_hgt*C))).^2 + ( dis2./(vclr/3) ).^2  ) );


Rtest3=sqrt( exp(  (dis./(hclr/3).*exp(2000./max_hgt*C) ).^2 + (dis2/(vclr/3))^2  )  ) ;
Rtest4=sqrt( exp(  (dis./(hclr/3).*exp(1000./max_hgt*C) ).^2 + (dis2/(vclr/3))^2  )  ) ;

% figure('position',[200 100 700 500])
% hp=plot(dis,Rtest);  set(hp,'LineWidth',2)
% xlabel('distant(m)','fontsize',16); 
% title('Weighting','fontsize',15)
%print('-dpng',[outdir,'weighting'],'-r350')  
% 
figure('position',[200 500 700 500])
hp=plot(dis,1./Rtest,'k');  set(hp,'LineWidth',2.5);   hold on;
hp=plot(dis,1./Rtest4,'r');  set(hp,'LineWidth',2.5)
hp=plot(dis,1./Rtest3,'g');  set(hp,'LineWidth',2.5)
hp=plot(dis,1./Rtest2,'b');  set(hp,'LineWidth',2.5)


set(gca,'XLim',[0 36000],'XTick',0:5000:36000,'XTickLabel',[0:5000:36000]./1000,'fontsize',14,'LineWidth',1)
xlabel('distant (km)','fontsize',15,'FontWeight','bold');  
hl=legend('original / h=0','h=1000m','h=2000m','h=3000m') ; set(hl,'Location','Best','fontsize',15) ;

tit='Weighting of R (inverse)';  title(tit,'fontsize',16,'FontWeight','bold')
outfile='/work/pwin/plot_cal/morakot/L-weighting.png'; print('-dpng',outfile,'-r400')  
%print('-dpng',outfile,'-r400') 

