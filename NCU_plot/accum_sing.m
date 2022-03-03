%function accum_sing(sth,acch,expri)
%function accum_sing(sth,acch,expri,textid,ctnid,seaid)
clear
%close all
sth=2; acch=5; expri='e47';  figtit='S1604';
textid=0;  ctnid=1;  seaid=2;  %2 for paper

%---experimental setting--------
dom='02'; year='2008'; mon='06'; date=16;      % experimental setting
%indir=['/SAS009/pwin/expri_whatsmore/',expri];  outdir=['/SAS011/pwin/201work/plot_cal/what/',expri];   % path of the figure output
%indir=['/SAS007/pwin/expri_sz6414/',expri];     outdir=['/SAS011/pwin/201work/plot_cal/IOP8/',expri];
indir=['/SAS009/pwin/expri_largens/',expri];    outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%indir=['/SAS011/pwin/what_plot/',expri];        outdir=['/SAS011/pwin/201work/plot_cal/what'];
%indir=['/SAS007/sz6414/IOP8/Goddard/forecast/fnlconst_all3'];  outdir=['/SAS011/pwin/201work/plot_cal'];
%indir='/SAS004/pwin/KUtest';  outdir='/SAS011/pwin/201work/plot_cal';
%-------------------------------
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';    cmap=colormap_rain; %cmap(1,:)=[0.9 0.9 0.9];
%------
varinam='accumulated rainfall';   filenam=[expri,'_accum_'];   
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=[filenam,'ctn',num2str(ctnid),'_']; end
if seaid~=0;  filenam=[filenam,'sea',num2str(seaid),'_']; end 
  
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
      end
      netcdf.close(ncid);
    end
    % make lakes on the land land 
    land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
    land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;  land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
%-----tick sea and let <0 =0, let 0=NaN------
    rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});
%    if seaid==0;  rain(land==0 | x<120)=NaN;  end
    rain(rain<0)=0;   rain(rain==0)=NaN;
    acci=rain; 
%------------    
    plot_accum(acci,x,y,ai,cmap,ctnid,textid,seaid);
      %tit=[expri,'  ',varinam,'  ',s_sth,'UTC -',s_edh,'UTC'];    title(tit,'fontsize',15)
      tit=(figtit);     title(tit,'fontsize',18,'Position',[-0.01 0.0285])
      outfile=[outdir,'/',filenam,s_sth,s_edh];
      %print('-dpng',outfile,'-r400')
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);   
      %}
  end  %ai
end  %ti
