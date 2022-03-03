clear

sth=2;  acch=7;  textid=0;  ctnid=1;  seaid=2;  

%-----------
year='2008'; mon='06'; date=16;      % time setting
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';    cmap=colormap_rain;  cmap(1,:)=[0.9 0.9 0.9];
%------
expri='QPESUMS';   varinam='accumulation rainfall';  filenam='qpesums_';
outdir='/SAS011/pwin/201work/plot_cal/Rain/obs/';
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn',num2str(ctnid),'_',filenam]; end
if seaid~=0;  filenam=['sea',num2str(seaid),'_',filenam]; end 

%---read model land data---
wrfout='/SAS007/pwin/expri_largens/WRF_shao/wrfout_d02_2008-06-15_18:00:00';
ncid = netcdf.open(wrfout,'NC_NOWRITE');
varid  =netcdf.inqVarID(ncid,'XLONG');     x =double(netcdf.getVar(ncid,varid));   
varid  =netcdf.inqVarID(ncid,'XLAT');      y =double(netcdf.getVar(ncid,varid)); 
varid  =netcdf.inqVarID(ncid,'LANDMASK');  land=double(netcdf.getVar(ncid,varid)); 
land(x>120.4 & x<121 & y>23 & y<24)=1;  land(x>120.55 & x<120.65 & y>22.45 & y<22.6)=1; 
land(x>120.2 & x<120.5 & y>23.15 & y<23.3)=1;   land(x>120.39 & x<120.46 & y>22.62 & y<22.72)=1; 
% ^^^ make lakes on the land land ^^^

for ti=sth
  s_sth=num2str(ti,'%2.2d');    s_date=num2str(date,'%2.2d');
  for ai=acch       % accumulation time
%---set clim and end time---    
    edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d'); 
%---read and add data---
    for j=1:ai
      hr1=ti+j-1;    hrday=fix((hr1+1)/24);   r_date=num2str(date+hrday,'%2.2d');  
      hr2=mod(ti+j,24);    r_hr2=num2str(hr2,'%2.2d');  
      infile=['/SAS004/pwin/data/QPESUMS/',year,mon,r_date,'/cb_rain01h_rad_gc/CB_GC_PCP_1H_RAD.',year,mon,r_date,'.',r_hr2,'00'];
      %infile=['/SAS004/pwin/data/obs_rain/QPESUMS/CB_GC_PCP_1H_RAD.',year,mon,r_date,'.',r_hr2,'00'];
      fid = fopen(infile,'r');
      A1 = fread(fid,9,'uint');     %date, domain size etc.
           fread(fid,[1 4],'*char');  %proj
      A2 = fread(fid,10,'uint');    %x, y axis
           fread(fid,A1(9),'*uint');      %zht
           fread(fid,11,'*uint');
           fread(fid,26,'*char');     %file, var name
      A3 = fread(fid,3,'int');
           fread(fid,[A3(3) 4],'*char');          
      rain = fread(fid,[A1(7) A1(8)],'int16');  
      fclose(fid);
%---
%       infile=['/SAS004/pwin/data/QPESUMS/CB_GC_PCP_1H_RAD.',year,mon,r_date,'.',r_hr2,'00.txt'];
%       A=importdata(infile);
%       if j==1; ny=size(A,1)/3; nx=size(A,2); end
%       rain=A(1+ny*2:end,:); rain=rain';
%---      
      rain=rain./4;  rain(rain<0)=0;
      if j==1; acc=zeros(A1(7),A1(8)); end
%       if j==1; acci=zeros(nx,ny); end
      acc=acc+rain;
    end        
%     x=A(1:ny,:); x=x';
%     y=A(1+ny:ny*2,:); y=flipud(y);  y=y';
    x0=A2(5)/A2(7)+ (0:A1(7)-1)*A2(8)/A2(10);               % x= x0+(0:nx-1)*dx
    y0=A2(6)/A2(7)-(0:A1(8)-1)*A2(9)/A2(10); y0=flipud(y0');  % y= y0+(0:ny-1)*dy
    [lat lon]=meshgrid(y0,x0);  
    
    %if seaid==0
     acci=griddata(lon,lat,acc,x,y,'cubic');
     acci(land==0 | x<120)=NaN;   acci(acci<=0)=NaN;
    %end
  
%---plot---
    %acci(acci<=0)=NaN;
    acc(acc<=0)=NaN;
    plot_accum(acci,x,y,ai,cmap,ctnid,textid,seaid) 
    %plot_accum(acc,lon,lat,ai,cmap,ctnid,textid,seaid) 
     tit=[expri,'  ',varinam,'  ',mon,s_date,' ',s_sth,'z -',s_edh,'z'];
     title(tit,'fontsize',15)
     outfile=[outdir,filenam,mon,s_date,s_sth,s_edh];
     %print('-dpng',outfile,'-r400')
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);  
  end
end
 
