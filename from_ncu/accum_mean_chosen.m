%----------------------------------------------------------
% Plot rainfall mean(w/ PM, PMmod) of chosen members
%----------------------------------------------------------

clear  
sth=10;   acch=2;   expri='0614e01';  member=[9 10 21]; 
textid=0; ctnid=1;  seaid=0;
plotid=[1 2 3]; % 1:mean, 2:PM, 3:PMmod
%---experimental setting---
indir=['/SAS007/pwin/expri_reas_IOP8/IOP8_',expri];       % path of the experiments
dom='02'; year='2008'; mon='06'; date=14;    % time setting
dirnam='pert';
outdir=['/SAS011/pwin/201work/plot_cal/IOP8/Rain/',expri];   % path of the figure output
%---set
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  cmap=colormap_rain;
%load '/work/pwin/data/heighti.mat';   [xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---
varinam='accu. rainfall';   filenam=[expri,'_accum_'];   
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn',num2str(ctnid),'_',filenam]; end
if seaid==1;  filenam=['sea_',filenam]; end 
type={'mean';'PM';'PMmod'};

%---
for ti=sth
  s_sth=num2str(ti,'%2.2d');   % start time string
  for ai=acch
    edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d');  
%---set ensemble filename---
    ni=0;
    for mi=member;
      for j=1:2;           
        hr=(j-1)*ai+ti;
        hrday=fix(hr/24);  hr=hr-24*hrday;    
        if date+hrday<10; s_date=['0',num2str(date+hrday)]; else s_date=num2str(date+hrday); end
        if hr<10;  s_hr=['0',num2str(hr)]; else  s_hr=num2str(hr); end   %%%   
        if mi<=9;  nen=['0',num2str(mi)];  else  nen=num2str(mi);  end
        infile=[indir,'/',dirnam,nen,'/wrfout_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,':00:00']; 
%------read netcdf data--------
        ncid = netcdf.open(infile,'NC_NOWRITE');
        varid  =netcdf.inqVarID(ncid,'RAINC');       rc{j}  =netcdf.getVar(ncid,varid); 
        varid  =netcdf.inqVarID(ncid,'RAINNC');      rnc{j} =netcdf.getVar(ncid,varid);   
      end      
      ni=ni+1;
      if ni==1
      varid  =netcdf.inqVarID(ncid,'XLONG');      lon =netcdf.getVar(ncid,varid);   x=double(lon);
      varid  =netcdf.inqVarID(ncid,'XLAT');       lat =netcdf.getVar(ncid,varid);   y=double(lat);
      varid  =netcdf.inqVarID(ncid,'LANDMASK');   land =netcdf.getVar(ncid,varid);
      % make lakes on the land land 
      land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
      land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;  land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
      end
      namem(ni*2-1:ni*2)=num2str(nen);  %record members for output file name
%-----tick sea and let <0 =0------
      rain=double(rc{2}-rc{1}+rnc{2}-rnc{1});          
      if seaid==0; rain(land==0 | x<120)=NaN;  end
      rain(rain<0)=0;    acci{ni}=rain;
        % acci=0 cannot be NaN, cause the function calPM.m assume the lenght of NaN is the same
      netcdf.close(ncid)
    end % Member
%---cal mean---
    [meacci PM PMmod]=calPM(acci);
%---plot----
    for pi=plotid   % 1:mean, 2:PM, 3:PMmod
      switch (pi); case 1; plotvar=meacci;  case 2; plotvar=PM; case 3; plotvar=PMmod;  end          
      plot_accum(plotvar,x,y,ai,cmap,ctnid,textid,seaid)
      tit=[expri,'  ',varinam,'  ',s_sth,'z -',s_edh,'z  (',type{pi},', mem',num2str(member),')'];
      title(tit,'fontsize',15)
      outfile=[outdir,'/',filenam,s_sth,s_edh,'_',type{pi},'_',namem];
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);      
    end %plot    
  end % accumulation interval
end % start hour
%
