%function accum_QPESUMS(sth,acch,textid,ctnid)
% sth: start time
% acch: accumulation time
% texid: Mark max value when texid~=0
% ctnid: same colorbar maximum=ctnid when ctnid~=0

clear; sth=15; acch=3; textid=0; ctnid=100; seaid=1;  

addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');    
load '/work/pwin/data/colormap_rain.mat';
cmap=colormap_rain;   cmap(1,:)=[0.9 0.9 0.9];
%---setting---
expri='QPESUMS obs';   vari='accumulation rainfall';  
%outdir='/work/pwin/plot_cal/Rain/obs/';
outdir='/work/pwin/plot_cal/IOP8/Rain/obs/';
filenam='QPESUMS_accum_';
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn',num2str(ctnid),'_',filenam]; end
if seaid==1;  filenam=['sea_',filenam]; end 
seaid=1;  inx=561; iny=441;
%---
for ti=sth
  s_sth=num2str(ti);         % time string
  for ai=acch                % accumulation time
%---set clim and end time---    
    edh=ti+ai;               % end time
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read and add data---
    for j=1:ai
      hr2=num2str(ti+j);  hr1=num2str(ti+j-1);      
      infile=['/SAS004/pwin/data/obs_rain/qpedata0614/20080614_',hr1,hr2,'_qpesums.dat'];
     % if ti+j==24; s_hr='00'; s_date='09'; else s_date='08'; s_hr=num2str(ti+j); end 
     % infile=['/SAS004/pwin/data/obs_rain/QPESUMS_rain/CB_GC_PCP_1H_RAD.200908',s_date,'.',s_hr,'00.dat'] ;    
      A=importdata(infile);  rain(:,j)=A(:,3); 
      fin=rain(:,j)<=0; rain(fin,j)=NaN;
    end
    acc=sum(rain,2);
    %[lon,lat]=meshgrid(118:0.0125:123.5,20:0.0125:27);
    n=0;
    for j=1:inx
      for k=1:iny   
        n=n+1;
        acci(j,k)=acc(n);
        lon(j,k)=A(n,1);
        lat(j,k)=A(n,2);
      end
    end
    acci=acci(1:2:inx,1:2:iny); lon=lon(1:2:inx,1:2:iny); lat=lat(1:2:inx,1:2:iny);
%---plot---
    plot_accum(acci,lon,lat,ai,cmap,ctnid,textid,seaid) 
    tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z'];
    title(tit,'fontsize',15)
    outfile=[outdir,filenam,s_sth,s_edh];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
    %}
  end
end
    
%end