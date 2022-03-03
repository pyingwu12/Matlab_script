clear
%----------------------------------------------------------
% Plot rainfall ensemble mean(w/ PM, PMmod), 
%              read data by function(aaccum_read_en) first
%----------------------------------------------------------
sth=00;   acch=1;   expri='largens';  ensize=256;  textid=0; ctnid=1;  seaid=2;
%(!!! remember to modify the date in the read function !!!)
plotid=[1 2];  % 1:mean, 2:PM, 3:PMmod

%---experimental setting---
%outdir=['/SAS011/pwin/201work/plot_cal/IOP8/Rain/',expri];   % path of the figure output
outdir=['/SAS011/pwin/201work/plot_cal/largens/',expri];
%outdir='/SAS011/pwin/201work/plot_cal/';
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_rain.mat';  cmap=colormap_rain;
%------
varinam='accumulation rainfall';   filenam=[expri,'_accum_'];   
if textid~=0; filenam=['Mar_',filenam]; end
if ctnid~=0;  filenam=[filenam,'ctn',num2str(ctnid),'_']; end
if seaid~=0;  filenam=[filenam,'sea',num2str(seaid),'_']; end 
type={'mean';'PM';'PMmod'};
 
%---
for ti=sth;
  s_sth=num2str(ti,'%2.2d');   % start time string
  for ai=acch;
    edh=mod(ti+ai,24);   s_edh=num2str(edh,'%2.2d');  % end time string
%---read ensemble data---
    [acci x y]=accum_read_en(ti,ai,expri,ensize,seaid);  
      % !!! Please remember to change the <indir> and <date> in this function. !!!
%---caculate mean---
    [meacci PM PMmod]=calPM(acci);   
%---plot    
%
    for pi=plotid   % 1:mean, 2:PM, 3:PMmod
      switch (pi); case 1; plotvar=meacci;  case 2; plotvar=PM; case 3; plotvar=PMmod;  end          
      plot_accum(plotvar,x,y,ai,cmap,ctnid,textid,seaid)
      tit=[expri,'  ',varinam,'  ',s_sth,'z -',s_edh,'z  (',type{pi},')'];
      title(tit,'fontsize',15,'Interpreter','none')
      outfile=[outdir,'/',filenam,s_sth,s_edh,'_',type{pi}];
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);           
    end %plot
  end  %ai
end  %ti

