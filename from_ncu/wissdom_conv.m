%-------------------
%  plot convergence and wind of wissdom data
%-------------------
%
clear

hr=3;    hgt_w =1500;  runid=1;
%
%---experimental setting---
year='2008'; mon='06'; date='16';   % time setting
outdir='/SAS011/pwin/201work//plot_cal/Wind/obs';
%---set
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_br.mat';  cmap=colormap_br([3 4 6 7 8 9 10],:);
%------
expri='WISSDOM';  varinam='conv.';  filenam=[expri,'_conv_'];
if runid~=0; filenam=['run_',filenam]; end
%plon=[118.3 122.85];  plat=[21.2 25.8];
plon=[118.9 121.8];   plat=[21 24.3];
L=[-7 -4 -1 1 4 7 ];
%--
addpath(['/SAS004/pwin/data/WISSDOM/',year,mon,'/']);
for ti=hr;
%---set time and filename---    
   s_hr=num2str(ti,'%2.2d');
%---read variables---
   [cover10 header]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'cover10');
   [u2b , ~]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'u2b'); 
   [v2b , ~]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'v2b');
   [rdivg2_b , ~]=read_grads(['realcase',mon,date,s_hr,'.ctl'],'rdivg2_b'); 
   x=header.XDEF.vec;
   y=header.YDEF.vec;
   z=header.ZDEF.vec;
   undef=header.UNDEF;
%---set x, y, lev---
   [yi xi]=meshgrid(y,x);  [nx ny]=size(xi);
   lev=find(z==hgt_w/1000);
   if isempty(lev)==1; error(['Without level ',num2str(hgt_w),'m, please try other levels']);  end
%---set no cover area
   int=7;
   cover=cover10(1:int:end,1:int:end,lev);
   xi2=xi(1:int:end,1:int:end);     yi2=yi(1:int:end,1:int:end);
   xcover=xi2(isnan(cover)==0);     ycover=yi2(isnan(cover)==0);
%---variables   
   u=u2b(:,:,lev);  v=v2b(:,:,lev);
   u(isnan(u)==1 | u==undef)=NaN;  v(isnan(v)==1 | v==undef)=0;%tick NaN
   u=u(1:int:end,1:int:end); v=v(1:int:end,1:int:end);
   %
   vari=-rdivg2_b(:,:,lev)*10^4;
   if runid~=0;
     plotvar=zeros(nx,ny);
     for i=2:nx-1
       for j=2:ny-1
        plotvar(i,j)=mean(mean(vari(i-1:i+1,j-1:j+1)));
       end
     end
   else
     plotvar=vari;
   end
%}
%--plot----
   pmin=double(min(min(plotvar)));   if pmin<L(1);  L2=[pmin L]; else L2=[L(1) L]; end
   figure('position',[500 100 600 500]) 
   m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121.9025,'parallels',[10 40],'rectbox','on') 
   [c hp]=m_contourf(xi,yi,plotvar);   set(hp,'linestyle','none');
   cm=colormap(cmap);    caxis([L2(1) L(length(L))])
   hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)
   %title(hc,'10^-^4 s^-^1','fontsize',14)
   %
   hold on;
   windmax=15;  scale=15;
   windbarbM_mapVer(xi2,yi2,u,v,scale,windmax,[0.15 0.2 0.25],0.6)
   windbarbM_mapVer(plon(1)+0.21,plat(2)-0.2,windmax,0,25,windmax,[0.8 0.05 0.1],1)
   m_text(plon(1)+0.21,plat(2)-0.2,num2str(windmax),'color',[0.8 0.05 0.1],'fontsize',12)
   %
   m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45);
   %m_coast('color','k','LineWidth',0.8);
   m_gshhs_h('color',[0.3 0.3 0.3],'LineWidth',0.8);
%---x marker---
   h=m_plot(xcover,ycover,'x');
   set(h,'linestyle','none','color',[0.3 0.3 0.3],'MarkerSize',4)
   %
   %tit=[expri,'  ',varinam,'  ',s_hr,'00z  (',num2str(hgt_w/1000),'km)'];  
   %title(tit,'fontsize',15)
   tit='WISSDOM';
   title(tit,'fontsize',17,'Position',[-0.024 0.0287])
   outfile=[outdir,'/',filenam,s_hr,'_',num2str(hgt_w/1000)];
    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
    system(['rm ',[outfile,'.pdf']]);  

end  %time
