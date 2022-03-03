%function TPWqx_diff(expri1,expri2)
%-------------------------------------------------------
% Difference(exp1-exp2) of integrate <vari>(qv,qr....) between expri1 to expri2  (DA cycle & forecasting time)
%-------------------------------------------------------

clear all
close all

vari='QVAPOR';
hr=2;  expri1='e02';  expri2='e01'; minu='00';   figtit1='S3604';   figtit2='L3604' ;

lev=12; 

%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/analmean';   type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir='/SAS009/pwin/expri_largens/';
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
L=[-5 -4 -3 -2 -1 -0.5 0.5 1 2 3 4 5];
%L=[-4 -3 -2 -1 -0.5 -0.2 0.2 0.5 1 2 3 4];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
%load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(2:14,:);
%------
s_vari=lower(vari(1:2));
varinam=['total-',s_vari,];  filenam=[expri1,'diff',expri2,'_','TPW',s_vari,'_conv'];
%plon=[117.5 122.5]; plat=[20.5 25.65]; 
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
g=9.81;

%----
for ti=hr
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');    % start time string
%---set filename---
   infile1=[indir,expri1,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
   infile2=[indir,expri2,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%====read netcdf data 1--------
   ncid = netcdf.open(infile1,'NC_NOWRITE');
   varid  =netcdf.inqDimID(ncid,'bottom_top');    [~, nz]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'south_north');   [~, ny]=netcdf.inqDim(ncid,varid);
   varid  =netcdf.inqDimID(ncid,'west_east');     [~, nx]=netcdf.inqDim(ncid,varid);
   dx =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX'));
   dy =double(netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY'));
   varid  =netcdf.inqVarID(ncid,'XLONG');   x =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'XLAT');    y =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,vari);      qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'U');      u1  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'V');      v1  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
   netcdf.close(ncid)
  %---integrate TPW---
   P=(pb+p);   
   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW1=sum(tpw,3)./g;
   %---
%   u1=(u_stag(1:end-1,:)+u_stag(2:end,:))*0.5;
%   v1=(v_stag(:,1:end-1)+v_stag(:,2:end))*0.5;
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,vari);      qr  =(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'P');       p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');      pb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'U');      u2  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx+1 ny 1 1]);
   varid  =netcdf.inqVarID(ncid,'V');      v2  =netcdf.getVar(ncid,varid,[0 0 lev-1 0],[nx ny+1 1 1]);
   
   netcdf.close(ncid)
  %---integrate TPW---
   P=(pb+p);   dP=P(:,:,1:nz-1)-P(:,:,2:nz);    
   tpw= dP.*( (qr(:,:,2:nz)+qr(:,:,1:nz-1)).*0.5 ) ;    
   TPW2=sum(tpw,3)./g; 
  %----
%   u2=(u_stag(1:end-1,:)+u_stag(2:end,:)).*0.5;
%   v2=(v_stag(:,1:end-1)+v_stag(:,2:end)).*0.5;
%-----------
   diff=TPW1-TPW2;   
   u.diff=u1-u2; v.diff=v1-v2;
%----------
%   int=5;
%   u.unstag=(u.diff(2:int:end,1:int:end)-u.diff(1:int:end-1,1:int:end))./dx;
%   v.unstag=(v.diff(1:int:end,2:int:end)-v.diff(1:int:end,1:int:end-1))./dy;
   u.unstag=(u.diff(2:end,:,:)-u.diff(1:end-1,:,:))./dx;
   v.unstag=(v.diff(:,2:end,:)-v.diff(:,1:end-1,:))./dy;
   conv=(u.unstag+v.unstag)*-10^4;
   rconv = zeros(nx-2,ny-2);
   for i=2:nx-1
     for j=2:ny-1
       rconv(i-1,j-1)=mean(mean(conv(i-1:i+1,j-1:j+1)));
     end
   end
%   x2=x(1:int:end,1:int:end); y2=y(1:int:end,1:int:end);
   x2=x(2:end-1,2:end-1); y2=y(2:end-1,2:end-1);
 
%---plot----
   plotvar=diff;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 200 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   %---
    m_contour(x2,y2,rconv,[1 1],'color','r','linewidth',1.5);
    m_contour(x2,y2,rconv,[-1 -1],'color','k','linewidth',1.2,'linestyle','-.');
   %---
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);  xlabel(hc,'(Kg/m^2)') 
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
   %
   %tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];
   %title(tit,'fontsize',15)

   tit=['PW   ',figtit1,'-',figtit2];
   title(tit,'position',[-0.0235 0.029],'fontsize',16);

   outfile=[outdir,'/',filenam,s_hr,minu,'_',type];  %print('-dpng',outfile,'-r400')       
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]); 
end    
