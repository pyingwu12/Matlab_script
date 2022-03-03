
clear
%close all
sth=2:6; acch=1; expri='e04'; textid=0;  ctnid=1;  
zhid=40;
%---experimental setting--------
dom='02'; year='2008'; mon='06'; date=16;      % time setting
indir=['/SAS009/pwin/expri_largens/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';    cmap=colormap_rain;
%------
seaid=2; 
varinam='accumulation rainfall';   filenam=[expri,'_accum-zh_'];   
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=[filenam,'ctn',num2str(ctnid),'_']; end
  
%---
for ti=sth;
  s_sth=num2str(ti,'%2.2d');   % start time string
  for ai=acch;
  edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d');   % end time string
%===wrf---set filename---
    for j=1:2;
      hr=(j-1)*ai+ti;
      hrday=fix(hr/24);  hr=hr-24*hrday;    
      s_date=num2str(date+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
      infile=[indir,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00'];
%------read netcdf data--------
      ncid = netcdf.open(infile,'NC_NOWRITE');
      varid  =netcdf.inqVarID(ncid,'RAINC');    rc{j}  =netcdf.getVar(ncid,varid);
      varid  =netcdf.inqVarID(ncid,'RAINNC');   rnc{j} =netcdf.getVar(ncid,varid);
      if j==1;
      varid  =netcdf.inqVarID(ncid,'XLONG');    lon =netcdf.getVar(ncid,varid);       x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');     lat =netcdf.getVar(ncid,varid);       y=double(lat);
      varid  =netcdf.inqVarID(ncid,'LANDMASK');  land=double(netcdf.getVar(ncid,varid)); 
      varid  =netcdf.inqVarID(ncid,'QRAIN');    qr  =double(netcdf.getVar(ncid,varid));  qr(qr<0)=0;
      varid  =netcdf.inqVarID(ncid,'QCLOUD');   qc  =double(netcdf.getVar(ncid,varid));  qc(qc<0)=0;
      varid  =netcdf.inqVarID(ncid,'QVAPOR');   qv  =double(netcdf.getVar(ncid,varid));  qv(qv<0)=0;
      varid  =netcdf.inqVarID(ncid,'QICE');     qi  =double(netcdf.getVar(ncid,varid));  qi(qi<0)=0;
      varid  =netcdf.inqVarID(ncid,'QSNOW');    qs  =double(netcdf.getVar(ncid,varid));  qs(qs<0)=0;
      varid  =netcdf.inqVarID(ncid,'QGRAUP');   qg  =double(netcdf.getVar(ncid,varid));  qg(qg<0)=0;
      varid  =netcdf.inqVarID(ncid,'P');        p   =double(netcdf.getVar(ncid,varid));
      varid  =netcdf.inqVarID(ncid,'PB');       pb  =double(netcdf.getVar(ncid,varid)); 
      varid  = netcdf.inqVarID(ncid,'T');       t   =double(netcdf.getVar(ncid,varid));
      end
      netcdf.close(ncid);
    end
    % make lakes on the land land 
    land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
    land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;  land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
%-----tick sea and let <0 =0, let 0=NaN------
    rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
    rain(rain<0)=0;   %rain(rain==0)=NaN;
    acci=rain; 
%-----calculate zh-----    
    [nx,ny,nz]=size(qv);  zh=zeros(nx,ny,nz);
    temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
    den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);    
    fin=find(temp < 273.15);
    zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
    fin=find(temp >= 273.15);
    zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.21e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
    zh_max=max(zh,[],3); 

%------------    
    plot_accum(acci,x,y,ai,cmap,ctnid,textid,seaid)
    hold on
    m_contour(x,y,zh_max,[zhid zhid],'color',[0.05 0.2 0.2],'Linewidth',1.1);
    m_text(120.9,21.1,['zh composite=',num2str(zhid)])
    
      tit=[expri,'  ',varinam,'  ',s_sth,'z -',s_edh,'z'];
      title(tit,'fontsize',15)
      outfile=[outdir,'/',filenam,s_sth,s_edh];
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);   
      %}
  end  %ai
end  %ti
