clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  cmap=colormap_rain; %cmap(1,:)=[0.9 0.9 0.9];

expri='0614e08'; s_sth='11'; s_edh='12';
ai=1; textid=0; ctnid=100; 

%[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
%---setting---
expdir=['/work/pwin/plot_cal/IOP8/Rain/',expri];
vari='accumulation rainfall';   type='PMmod';    
filenam=[expri,'_accum-MRf_'];   
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0 && ctnid~=1;  filenam=['ctn_',filenam]; end

%---read data---
load ([expdir,'/MRfcst_',s_sth,s_edh,'.mat'])
acci=wrfacci;    
  [meacci PM PMmod]=calPM(acci);     
%---plot--- 
  plot_accum(PMmod,xi,yj,ai,cmap,ctnid,textid)
  tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type,')'];
  title(tit,'fontsize',15)
  outfile=[expdir,'/',filenam,s_sth,s_edh,'_',type,'.png'];
  print('-dpng',outfile,'-r350')       

