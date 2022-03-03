%-------------------------------------------------------
% Caculate and plot profile of equivalent potential temperature of a single run 
%  (DA cycle & forecasting time), 
%-------------------------------------------------------

clear

hr=2;   minu='00';   expri='e01';  

lonA=119; latA=23.2;  len=2.5;   %length of the line (degree)
slopx=1; %integer and >= 0
slopy=0; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';    type='sing';
%infilenam='output/analmean';  type=infilenam(8:11);  %!!!!

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir=['/SAS005/pwin/expri_shao/',expri];   outdir=['/SAS011/pwin/201work/plot_cal/IOP8_shao/',expri];    % path of the experiments
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
L=[50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80]; 
%L=[20 25 30 35 40 45 50 55 60 65 70 75]; 

%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_wind.mat';  cmap=colormap_wind; 
%---
varinam='Theta e';    filenam=[expri,'_The-prof_'];  
zgi=[10,50,100:100:10000];    ytick=1000:1000:zgi(end); 
g=9.81;
%---coeffitions--
 cp=1005;  % J/(K*kg)
 Lat=2430; % J/g
 Lc=2.5e6; % J/Kg
 R=287.43;
 eps=0.622; % esp=Rd/Rv=Mv/Md
 A=1.26e-3;  % K^-1
 B=5.14e-4;  % K^-1

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
   varid  =netcdf.inqVarID(ncid,'T');        t   =netcdf.getVar(ncid,varid);  T=t+300; %potential temprature
   varid  =netcdf.inqVarID(ncid,'P');        p   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PB');       pb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
    netcdf.close(ncid)
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;   zg=double(PH)/g; 
%---caculate equivalent potential temperature---
   P=p+pb;    
   ev=qv./eps.*P/100;   %partial pressure of water vapor
   Td=-5417./(log(ev./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor
   Tlcl=(1-A.*Td)./(1./Td+B.*log(T./Td)-A);    
   the=T.*exp(Lc.*qv./(cp.*Tlcl));
   the=the-273;
   %
%---difine xp, yp for profile---
   dis= ( (y-latA).^2 + (x-lonA).^2 );
   [mid mxI]=min(dis);    [dmin py]=min(mid);    px=mxI(py);    
%---interpoltion---    
   i=0;  lonB=0; latB=0;
   while lonB<=x(px,py)+len && latB<=y(px,py)+len
     i=i+1;
     indx=px+slopx*(i-1);    indy=py+slopy*(i-1);
     linex(i)=x(indx,indy);  lonB=linex(i);     
     liney(i)=y(indx,indy);  latB=liney(i);       
     X=squeeze(zg(indx,indy,:));   Y=squeeze(the(indx,indy,:));   varprof(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end  
   
%---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
   end
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   if slopx==0; slope=1; else slope=fixpy(slopy/slopx,0.01); end   
%--plot----
   plotvar=varprof;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %   
   figure('position',[400 500 750 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(^oC)')
   %
   plot(xaxis,hgtprof,'k','LineWidth',1.5);  %terrain
   text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',num2str(slope)])
   %
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   tit=[expri,'  ',varinam,'  ',s_hr,minu,'z  (',type,')']; 
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',num2str(px),num2str(py),'s',slope];  
   %print('-dpng',outfile,'-r400')       
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);      

end  %ti
