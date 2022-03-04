% sth: start time
% acch: accumulation time
% expri: experiment name
% member: ensemble member you want to plot  
% texid: Mark max value when texid~=0
% ctnid: same colorbar maximum=ctnid when ctnid~=0

clear; sth=11; acch=1; expri='0614e08'; 
member=[5 15 14 35 18 12];
type='bestmean_landsea6';

textid=0; ctnid=100;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  cmap=colormap_rain; cmap(1,:)=[0.9 0.9 0.9];
%---setting---
vari='accumulation rainfall';    
filenam=[expri,'_accum_'];   expdir=['/work/pwin/plot_cal/IOP8/Rain/',expri];
  if textid~=0; filenam=['Mar_',filenam]; end
  if ctnid~=1;  filenam=['ctn_',filenam]; end
%---
for ti=sth;
  s_sth=num2str(ti);
  for ai=acch;
%---set clim and end time---    
    edh=ti+ai;               % end time
    if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
    %infile=[expdir,'/sea_acci_',s_sth,s_edh,'.mat'];
    infile=[expdir,'/MRfcst_sea_',s_sth,s_edh,'.mat'];   %%%%
    load (infile); acci=wrfacci;
    ni=0;
    for mi=member;
      ni=ni+1;
      wacci{ni}=acci{mi};
    end  %member
    [meacci PM PMmod]=calPM(wacci);   
    meacci(meacci<=0)=NaN;
%---plot---   
    plot_accum(meacci,xi,yj,ai,cmap,ctnid,textid)  
     tit=['0614e02','  ',vari,'  ',s_sth,'z -',s_edh,'z','  (bestmean)'];
    title(tit,'fontsize',15)
     outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type,'.png'];
    print('-dpng',outfile,'-r350')    
  end  %accumulation time
end  %start time

