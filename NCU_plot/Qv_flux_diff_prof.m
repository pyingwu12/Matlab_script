%-------------------------------------------------------
% Difference(exp1-exp2) of qv flux between expri1 to expri2  (DA cycle & forecasting time)
%-------------------------------------------------------

clear

hr=2;  minu='00';  
expri1='e38';  expri2='e02'; %figtit1='L3604'; figtit2='S3604';

lonA=120.2; latA=21.75;  len=1.5; %length of the line (degree)
slopx=0; %integer and >= 0
slopy=1; %integer and >= 0

% lonA=118.8; latA=22.4;  len=2.5;  slopx=1;  slopy=0; %integer and >= 0

%---DA or forecast time---
infilenam='wrfout';        type='sing';
%infilenam='output/analmean';    type=infilenam(8:11);

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
%indir='/SAS009/pwin/expri_whatsmore/';       % path of the experiments
%indir='/SAS005/pwin/expri_shao/';
indir='/SAS009/pwin/expri_largens/'; outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri1];   % path of the figure output
 L=[ -40 -30 -20 -10 -5 -1  1 5 10 20 30 40];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
%load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  
load '/work/pwin/data/colormap_br3.mat';  cmap=colormap_br3(2:14,:);
%------
varinam='Qv flux';  filenam=[expri1,'-diff-',expri2,'_qv-flux_prof_'];
zgi=[10,50,100:100:11000]';    ytick=1000:1000:zgi(end); 
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
   varid  =netcdf.inqVarID(ncid,'XLONG');   lon =netcdf.getVar(ncid,varid);     x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');    lat =netcdf.getVar(ncid,varid);     y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QVAPOR');  qv  =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'U');       u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');       v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');       ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');      phb  =netcdf.getVar(ncid,varid); 
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;   zg1=double(PH)/g; 
   u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
   v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
   if slopx>=slopy;  qf1=v.unstag.*qv*1000; else;  qf1=u.unstag.*qv*1000; end
   netcdf.close(ncid)
%====read netcdf data 2----
   ncid = netcdf.open(infile2,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'QVAPOR');    qv =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'U');         u.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'V');         v.stag =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PH');          ph   =netcdf.getVar(ncid,varid);
   varid  =netcdf.inqVarID(ncid,'PHB');         phb  =netcdf.getVar(ncid,varid); 
   P0=double(phb+ph);    PH=(P0(:,:,1:end-1)+P0(:,:,2:end)).*0.5;   zg2=double(PH)/g; 
   u.unstag=(u.stag(1:end-1,:,:)+u.stag(2:end,:,:)).*0.5;
   v.unstag=(v.stag(:,1:end-1,:)+v.stag(:,2:end,:)).*0.5;
   if slopx>=slopy;  qf2=v.unstag.*qv*1000; else;  qf2=u.unstag.*qv*1000; end
   netcdf.close(ncid)
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
     X=squeeze(zg1(indx,indy,:));   Y=squeeze(qf1(indx,indy,:));   var1(:,i)=interp1(X,Y,zgi,'linear');
     X=squeeze(zg2(indx,indy,:));   Y=squeeze(qf2(indx,indy,:));   var2(:,i)=interp1(X,Y,zgi,'linear');
     hgtprof(i)=hgt(indx,indy);
   end  
   diff=var1-var2;    
%---plot setting---   
   if slopx>=slopy;    xtitle='Longitude';  [xi zi]=meshgrid(linex,zgi);  xaxis=linex;
   else               xtitle='Latitude';   [xi zi]=meshgrid(liney,zgi);  xaxis=liney;
   end
   pointA=['A(',num2str(linex(1),4),',',num2str(liney(1),3),')'];
   pointB=['B(',num2str(linex(end),4),',',num2str(liney(end),3),')'];
   if slopx==0; slope='Inf'; else slope=num2str(slopy/slopx,2); end
%--plot----
   plotvar=diff;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[400 100 750 500]) 
   [c hp]=contourf(xi,zi,plotvar,L2);   set(hp,'linestyle','none');  hold on;
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1);   title(hc,'(g Kg^-^1ms^-^1)')
   %
   plot(xaxis,hgtprof,'k','LineWidth',1.5);  %terrain
   %text(xaxis(1)+0.1,zgi(end)-zgi(end)/20,[pointA,' ',pointB,' slope=',slope])  %label
   %
   set(gca,'Ytick',ytick,'Yticklabel',ytick./1000,'fontsize',13)
   xlabel(xtitle,'fontsize',14); ylabel('Height (km)','fontsize',14)
   %
   tit=[expri1,' minus ',expri2,'  ',varinam,'  ',s_hr,minu,'z  (',type,')'];
   %tit=['QVAPOR flux difference  LimVr-S3604'];
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,minu,'_',type,'_',num2str(px),num2str(py),'s',slope];  %print('-dpng',outfile,'-r400')       
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]); 
end    
