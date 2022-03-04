%function accum_mean(sth,acch,expri,textid,ctnid)
% sth: start time
% acch: accumulation time
% expri: experiment name
% plotid: mean=1 PM=2 PMmod=4, PM+mean=3 and so on...
% texid: Mark max value when texid~=0
% ctnid: same colorbar maximum=ctnid when ctnid~=0
clear
sth=18; acch=3; expri='orig'; textid=0; ctnid=0;

addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  
cmap=colormap_rain;   
%---setting---
vari='accumulation rainfall';  expdir=['/work/pwin/plot_cal/Rain/',expri];
filenam=[expri,'_accum-Mmb_'];   
type='member';
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=['ctn_',filenam]; end
%---
for ti=sth;
   s_sth=num2str(ti);
   for ai=acch;
%---set end time---    
      edh=ti+ai;               % end time
      if edh==24; s_edh='00'; else s_edh=num2str(edh); end     % time string
%---read data---    
      infile=[expdir,'/acci_',s_sth,s_edh,'.mat'];
      load (infile);
      
      [mem]=mean_member(sth,acch,expri);      
      nen=num2str(mem);
%---plot---
      plot_accum(acci{mem},xi,yj,ai,cmap,ctnid,textid)  
      tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type,nen,')'];
      title(tit,'fontsize',15)
      outfile=[expdir,'/',filenam,s_sth,s_edh,'_m',nen,'.png'];
      print('-dpng',outfile,'-r350')

   end
end  
%}
