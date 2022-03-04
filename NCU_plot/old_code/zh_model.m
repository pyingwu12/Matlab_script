
clear

hr=7;   expri='szvrzh364';  
%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';  minu='00';  % time setting
infilenam='wrfout';  
%infilenam='output/fcstmean';
indir=['/SAS009/pwin/expri_largens/',expri]; outdir=['/work/pwin/plot_cal/largens/',expri,'/'];   % path of the figure output
%indir=['/SAS009/pwin/expri_cctmorakot/',expri]; outdir=['/work/pwin/plot_cal/morakot_shao/',expri,'/'];   % path of the figure output
%L=[1 2 6 10 14 18 22 26 30 34 38 42 46 50 55 60];
%L=[2 6 10 14 18 21 24 27 30 33 35 37 39 41 43 45];
L=[2 6 10 14 18 21 24 27 30 33 35 37 39 42 45 48];
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_zh.mat';  cmap=colormap_zh;
%------
vari='Zh';    filenam=[expri,'_zhmodel_']; 
plon=[118.3 122.85];  plat=[21.2 25.8];
g=9.81;
latp=23.6; lonp=120.1;     zgi=[10,50,100:100:10000]';


for ti=hr;
%---set filename---
   if  ti<10; s_hr=['0',num2str(ti)]; else s_hr=num2str(ti); end   % start time string
   infile=[indir,'/',infilenam,'_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];
%------read netcdf data--------
   ncid = netcdf.open(infile,'NC_NOWRITE');
   varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);    x=double(lon);
   varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);    y=double(lat);
   varid  =netcdf.inqVarID(ncid,'QRAIN');    qr  =double(netcdf.getVar(ncid,varid));  qr(qr<0)=0;
   varid  =netcdf.inqVarID(ncid,'QCLOUD');   qc  =double(netcdf.getVar(ncid,varid));  qc(qc<0)=0;
   varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));  qv(qv<0)=0;
   varid  =netcdf.inqVarID(ncid,'QICE');     qi  =double(netcdf.getVar(ncid,varid));  qi(qi<0)=0;
   varid  =netcdf.inqVarID(ncid,'QSNOW');    qs  =double(netcdf.getVar(ncid,varid));  qs(qs<0)=0;
   varid  =netcdf.inqVarID(ncid,'QGRAUP');   qg  =double(netcdf.getVar(ncid,varid));  qg(qg<0)=0;
   varid  =netcdf.inqVarID(ncid,'P');        p   =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PB');       pb  =double(netcdf.getVar(ncid,varid)); 
   varid  =netcdf.inqVarID(ncid,'PH');       ph  =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'PHB');      phb =double(netcdf.getVar(ncid,varid)); 
   varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
   varid  =netcdf.inqVarID(ncid,'HGT');      hgt =double(netcdf.getVar(ncid,varid)); 
   netcdf.close(ncid)
%-------- 
    [nx,ny,nz]=size(qv);
   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
   
   %{
   %!!!!check the coeffitian of the operator
   zh=zeros(nx,ny,nz);   
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+9.80e8*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);

   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+4.26e11*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);
   zh(zh<0)=0;
   %}
   %
   
   zh=zeros(nx,ny,nz);   
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);

   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.12e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
   %zh(zh<0)=0;  
   %}   
   
%    zh=43.1+17.5*log10(den.*qr.*1.e3);
%    zh(zh<0)=0;
     
   [nx ny nz]=size(zh);
   %%
   for i=1:nx
     for j=1:ny
       var(i,j)=max(zh(i,j,:));
     end
   end
    
%---plot---
   plotvar=var;   plotvar(plotvar==0)=NaN;
   pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
   figure('position',[600 500 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   %[c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none'); 
   [c hp]=m_contour(x,y,plotvar,[40 40],'r'); hold on
   [c hp]=m_contour(x,y,plotvar,[25 25],'b');
   [c hp]=m_contour(x,y,plotvar,[10 10],'g');
   %clabel(c,hp,'fontsize',10,'color',[0.1 0.1 0.1]);  
   set(hp,'linewidth',1.5);
   hold on
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   m_coast('color','k');
   %m_gshhs_h('color','k','LineWidth',0.8);
   %colorbar
   %colormap(jet); caxis([0 50])
   %cm=colormap(cmap);     %caxis([0 60])  
   %hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_sing.png'];
   %print('-dpng',outfile,'-r400')  
 %%
  %-------------
   
%    P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
%    zg=PH/g;
%    
%    dis= ( (y-latp).^2 + (x-lonp).^2 );
%    [mid mxI]=min(dis);    [dmin yp]=min(mid);    xp=mxI(yp); 
% 
%       hgt_prof=hgt(:,yp);
%       
%       proflabel=['(',num2str(mean(y(100:220,yp))),'°N)'];
%      
% %---interpolation to z-axis----
%     for i=1:nx
%       X=squeeze(zg(i,yp,:));
%       Y=squeeze(zh(i,yp,:));
%       var_prof(:,i)=interp1(X,Y,zgi,'linear');
%     end
%    
%    [xi zi]=meshgrid(x(:,yp),zgi);      
%     var_plot=var_prof;   var_plot(var_plot==0)=NaN;
%     pmin=double(min(min(var_plot)));   if pmin<L(1); L2=[pmin,L]; else  L2=[L(1) L]; end
%    %
%    figure('position',[100 500 700 500]) 
%    [c hp]=contourf(xi,zi.*0.001,var_plot,L2);   set(hp,'linestyle','none');  
%    colorbar
%    colormap(jet); caxis([0 50])
%    %cm=colormap(cmap);  %caxis([L2(1) L(length(L))])  
%    %hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%    
%    hold on; 
%    plot(xi,hgt_prof.*0.001,'k','LineWidth',1.5);
%    set(gca,'XLim',[119 121.8],'YLim',[0 10],'fontsize',13,'LineWidth',1);   xlabel('Longtitude'); ylabel('height(km)')
%    %
%    tit=[expri,'  ',vari,'  ',s_hr,'z  ',proflabel];
%    title(tit,'fontsize',15)
%    outfile=[outdir,filenam,s_hr,'_prof',num2str(latp),'.png'];
%    print('-dpng',outfile,'-r400')   
%    
   

end  %ti
