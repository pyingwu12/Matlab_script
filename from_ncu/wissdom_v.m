
clear

hr=3;    hgt_w =1500;  
%
%---experimental setting---
year='2008'; mon='06'; date='16';   % time setting
outdir='/work/pwin/plot_cal/Zh/obs';
%L=[-11 -9 -7 -5 -3 -1 1 3 5 7 9 11];
L=[-15 -10 -7 -5 -3 -1 1 3 5 7 10 15];
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/');     
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br;  cmap(7,:)=[0.85 0.85 0.85]; 
%------
expri='WISSDOM';  varinam='V';  filenam=[expri,'_v_'];
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.3 121.8];   plat=[21 24.3];
qscale=0.008;

%--
addpath(['/SAS004/pwin/data/WISSDOM/',year,mon,'/']);
for ti=hr;
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');
%---read variables---
   [cover10 header]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'cover10');
   [u2b , ~]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'u2b'); 
   [v2b , ~]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'v2b');
   x=header.XDEF.vec;
   y=header.YDEF.vec;
   z=header.ZDEF.vec;
   undef=header.UNDEF;
%---set x, y, lev---
   [yi xi]=meshgrid(y,x);  [nx ny]=size(xi);
   lev=find(z==hgt_w/1000);
%---set no cover area
   int=8;
   cover=cover10(1:int:end,1:int:end,lev);
   xi2=xi(1:int:end,1:int:end);     yi2=yi(1:int:end,1:int:end);
   xcover=xi2(isnan(cover)==0);     ycover=yi2(isnan(cover)==0);
%---variables   
%    u=u2b(:,:,lev);  v=v2b(:,:,lev);
%    u(isnan(u)==1 | u==undef)=0;  v(isnan(v)==1 | v==undef)=0;%tick NaN
%    u=u(1:int:end,1:int:end); v=v(1:int:end,1:int:end);
%---set variable    
   vari=v2b(:,:,lev); 
   vari(vari==undef)=NaN;  %tick NaN
   plotvar= vari;
%--plot----
   pmin=double(min(min(plotvar)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   %
   figure('position',[500 500 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(xi,yi,plotvar,L2);   set(hp,'linestyle','none');  hold on;    
   cm=colormap(cmap);  caxis([L2(1) L(length(L))])  
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)  
   %
%    h1 = m_quiver(xi2,yi2,u,v,0,'k') ; % the '0' turns off auto-scaling
%    hU = get(h1,'UData');   hV = get(h1,'VData') ;
%    set(h1,'UData',qscale*hU,'VData',qscale*hV,'LineWidth',1.2);  
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1);
   %m_coast('color','k');
   m_gshhs_h('color','k','LineWidth',0.8);    
%---x marker---
   h=m_plot(xcover,ycover,'x');
   set(h,'linestyle','none','color',[0.3 0.3 0.3],'MarkerSize',4)
   %
   tit=[expri,'  ',varinam,'  ',s_hr,'00z  (',num2str(hgt_w/1000),'km)'];  
   title(tit,'fontsize',15)
   outfile=[outdir,'/',filenam,s_hr,'_',num2str(hgt_w/1000)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  
end
