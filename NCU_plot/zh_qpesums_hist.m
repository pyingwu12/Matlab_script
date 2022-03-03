clear

hr=1:5; 
%-----------
year='2008'; mon='06'; date='16';      % time setting
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_zh2.mat';    cmap=colormap_zh2;  
%------
expri='QPESUMS';   varinam='zh comp.';  filenam='zh-qpesums-hist_';
outdir='/SAS011/pwin/201work/plot_cal/Zh/obs/';

range=0:5:55;

for ti=hr
  s_hr=num2str(ti,'%2.2d');   
  infile=['/SAS004/pwin/data/obs_rain/QPESUMS/COMPREF.',year,mon,date,'.',s_hr,'00'];
  fid = fopen(infile,'r');
  A1 = fread(fid,9,'uint');       %date, domain size etc.
       fread(fid,[1 4],'*char');  %proj
  A2 = fread(fid,10,'uint');      %x, y axis
       fread(fid,A1(9),'*uint');  %zht
       fread(fid,11,'*uint');
       fread(fid,26,'*char');     %file, var name
  A3 = fread(fid,3,'int');
       fread(fid,[A3(3) 4],'*char');          
  zh = fread(fid,[A1(7) A1(8)],'int16');  
  fclose(fid);
      
  zh=zh./10; 

  zh_max2=zh(zh>=-5);
%--histogram   
  hi=cal_histc(zh_max2,range);  hi=hi./length(zh_max2).*100;
   
%---plot
   len=length(range)+1;
   
   figure('position',[100 500 800 500]) 
   hb=bar(1:len,hi);    colormap([0.5 0.87 0.96]);
   %
   set(gca,'fontsize',13,'XLim',[0 len+1],'XTick',0.5:len+0.5,'XTickLabel',[-inf,range,inf])
   set(gca,'YLim',[0 max(hi)+1])
   xlabel('dBZ','fontsize',14);   ylabel('number(%)','fontsize',14);
%---
   tit=[expri,'  ',varinam,'  ',s_hr,'z'];
   title(tit,'fontsize',15)
   outfile=[outdir,filenam,s_hr];
   %print('-dpng',outfile,'-r400') 
     set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
     system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
     system(['rm ',[outfile,'.pdf']]);      
end
 