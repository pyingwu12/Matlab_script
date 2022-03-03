clear

hr=2; 
%-----------
year='2008'; mon='06'; date='16';      % time setting
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_zh2.mat';    cmap=colormap_zh2;  
%------
expri='QPESUMS';   varinam='zh';  filenam='zh-qpesums_';
outdir='/SAS011/pwin/201work/plot_cal/Zh/obs/';

%L=[2 6 10 14 18 22 26 30 34 38 42 46 50];
%L=[2 6 10 14 18 21 24 27 30 33 35 37 39 42 45 48];
%L=[2 6 10 14 18 22 25 28 31 34 37 40 43 46 49 52];
%L=[1 2 6 10 14 18 22 26 30 34 38 42 46 50 55 60];
L=[0 5 10 15 20 25 30 35 40 45 50 55 60 65];
%plon=[118.3 122.85];  plat=[21.2 25.8];; 
%plon=[118.3 121.8];   plat=[21 24.3];
plon=[118.2 122.8];       plat=[19.8 25.9];


for ti=hr
  s_hr=num2str(ti,'%2.2d');   
  infile=['/SAS004/pwin/data/QPESUMS/',year,mon,date,'/compref_mosaic/COMPREF.',year,mon,date,'.',s_hr,'00'];
  fid = fopen(infile,'r');
  A1 = fread(fid,9,'uint');       %date, domain size etc.
       fread(fid,[1 4],'*char');  %proj
  A2 = fread(fid,10,'uint');      %x, y axis
       fread(fid,A1(9),'*uint');  %zht
       fread(fid,11,'*uint');
       fread(fid,26,'*char');     %file, var name
  A3 = fread(fid,3,'int');
       fread(fid,[4 A3(3)],'*char');          
  zh = fread(fid,[A1(7) A1(8)],'int16');  
  fclose(fid);
  x0=A2(5)/A2(7)+ (0:A1(7)-1)*A2(8)/A2(10);                 % x= x0+(0:nx-1)*dx
  y0=A2(6)/A2(7)-(0:A1(8)-1)*A2(9)/A2(10); y0=flipud(y0');  % y= y0+(0:ny-1)*dy
  [y x]=meshgrid(y0,x0); 
%---
%   infile=['/SAS004/pwin/data/QPESUMS/COMPREF.',year,mon,date,'.',s_hr,'00.txt'];
%   A=importdata(infile);
%   ny=size(A,1)/3;
%   x=A(1:ny,:); x=x';
%   y=A(1+ny:ny*2,:); y=flipud(y);  y=y';
%   zh=A(1+ny*2:end,:); zh=zh';
%---
  zh=zh./10; 
  
%---plot---
  plotvar=zh;   plotvar(plotvar==0)=NaN;
  pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
    %
  figure('position',[100 100 600 500])
  m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
  [c hp]=m_contourf(x,y,plotvar,L2);   set(hp,'linestyle','none'); hold on
  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
  %m_coast('color','k');
  m_gshhs_h('color','k','LineWidth',0.8);
  colorbar;  cm=colormap(cmap);     caxis([0 60])  
  hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
  tit=[expri,'  ',varinam,'  ',mon,date,' ',s_hr,'z'];
  title(tit,'fontsize',15)
  outfile=[outdir,filenam,mon,date,s_hr];
  %print('-dpng',outfile,'-r400')
  set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
  system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
  system(['rm ',[outfile,'.pdf']]);   
end
 
