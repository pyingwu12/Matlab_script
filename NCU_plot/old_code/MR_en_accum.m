clear
addpath('/work/zerocustom/matlabLibrary/m_map_v1.4f/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  cmap=colormap_rain; cmap(1,:)=[0.9 0.9 0.9];

expri='0614e09'; s_sth='11'; s_edh='12'; seaid=1;
ai=1; textid=0; ctnid=100; member=[36 3 14 18 35]; 

%---setting---
%[xi,yj]=meshgrid(120:0.05:122,21.65:0.05:25.65);
expdir=['/work/pwin/plot_cal/IOP8/Rain/',expri];
vari='accumulation rainfall';    type='member';  filenam=[expri,'_accum-MRf_'];   
  if textid~=0; filenam=['Mar_',filenam]; end
  if ctnid~=0 && ctnid~=1;  filenam=['ctn_',filenam]; end
  if seaid~=0; filenam=['sea_',filenam]; end
%---    
if seaid~=0;  load ([expdir,'/MRfcst_sea_',s_sth,s_edh,'.mat']);
else  load ([expdir,'/MRfcst_',s_sth,s_edh,'.mat']); end
acci=wrfacci; 
%---
    for mi=member;
      nen=num2str(mi);
      acci{mi}(acci{mi}==0)=NaN;
%---plot---
      plot_accum(acci{mi},xi,yj,ai,cmap,ctnid,textid);
      tit=[expri,'  ',vari,'  ',s_sth,'z -',s_edh,'z','  (',type,nen,')'];
      title(tit,'fontsize',15);
      outfile=[expdir,'/',filenam,s_sth,s_edh,'_m',nen,'.png'];
      print('-dpng',outfile,'-r350')
    end  %member


