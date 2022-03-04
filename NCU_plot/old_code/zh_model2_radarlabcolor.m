clear

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
%load '/work/pwin/data/colormap_rain.mat';  cmap=colormap_rain([1 2 3 4 6 7 8 10 11 13 14 16 17],:);

cmap=[     0.6863    0.6863    0.6863;
          0    1.0000    1.0000;
          0    0.5882    1.0000;
          0         0    1.0000;
          0    1.0000         0;
          0    0.7843         0;
          0    0.5882         0;
     1.0000    1.0000         0;
     1.0000    0.7843         0;
     1.0000    0.4706         0;
     1.0000         0         0;
     0.7843         0         0;
     0.5882         0         0;
     1.0000         0    1.0000;
     0.5882         0    0.9804;
     1.0000    1.0000    1.0000;
     0.8235    0.7843    0.9020;
     0.4       0.4       0.4   ];


%---set---
sth=22;      expri='vrzh364';   vari='Zh composite';    filenam=[expri,'_zhcom_'];   
indir=['/SAS002/pwin/expri_241/morakot_sing_',expri];
outdir=['/work/pwin/plot_cal/morakot/',expri];
s_date='08';
%---
%L=[5 10 15 20 25 30 35 40 45 50 55 ];
plon=[117.8 122.6]; plat=[21 25.5];
g=9.81;

for ti0=sth;
%---set filename---
   hrday=fix(ti0/24);  ti=ti0-24*hrday;  %s_date=num2str(date+hrday);    %%%
   if ti<10;  s_hr=['0',num2str(ti)];  else  s_hr=num2str(ti);  end   %%%      
   infile=[indir,'/wrfout_d03_2009-08-',s_date,'_',s_hr,':00:00'];   
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
   varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
   netcdf.close(ncid)
%-------- 
   [nx,ny,nz]=size(qv);
   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);
   
   %!!!!check the coeffitian of the operator
   zh=zeros(nx,ny,nz);   
   fin=find(temp < 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+9.80e8*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);

   fin=find(temp >= 273.15);
   zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+4.26e11*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);
   zh(zh<0)=0;
   
   %P0=(phb+ph);   PH=(P0(:,:,1:nz)+P0(:,:,2:nz+1)).*0.5;
   %zg=PH/g;
  
   
   [nx ny nz]=size(zh);
   
   for i=1:nx
     for j=1:ny
       var(i,j)=max(zh(i,j,:));
     end
   end
   

   plotvar=var;   plotvar(plotvar==0)=NaN;
   %pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
   figure('position',[600 100 600 500])
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
   [c hp]=m_contourf(x,y,plotvar,18);   set(hp,'linestyle','none'); hold on
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   %m_gshhs_h('color','k','LineWidth',0.8);
   colorbar;  cm=colormap(cmap);     caxis([0 60])  
   %hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1.1)  
%---
   tit=[expri,'  ',vari,'  ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr,'_sing.png'];
   %print('-dpng',outfile,'-r400')  

end  %ti
