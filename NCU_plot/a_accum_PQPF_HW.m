
clear
% 
addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
load '/work/pwin/data/colormap_PQPF.mat';  cmap=colormap_PQPF; cmap(1,:)=[0.85 0.85 0.85];
% 
% load '/SAS005/juliechang/ForHW/heighti'
% [xlon,ylat]=meshgrid(120:0.05:122,21.65:0.05:25.65);
% 
% EnsMembers=zeros(414,72);
% for ti=1:times
%   s_hr=num2str(ti,'%2.2d');
% infile=['/SAS005/juliechang/ForHW/hourlyRainfall_obsAndEnsFcst/hourlyRainfall_obsAndEnsFcstD03_20080616',s_hr,'.txt'];
% Data = importdata(infile);
% EnsMembers   = Data(:,5:76)+EnsMembers;
% end
% Lon  = Data(:,1);
% Lat  = Data(:,2);
% %fin=find(isnan(heighti)==1);
% for i=1:memsize
% acci{i}=griddata(Lon,Lat,EnsMembers(:,i),x,y);
% %acci{i}(isnan(heighti)==1 | heighti<0 )=NaN;
% end
 plon=[118.5 123.2];       plat=[21.65 26.35];

 times=20; memsize=21;
 L=5:5:95;
yl=330; xl=330;

%[acci x y]=accum_read_en(0,times,'e18_ensfcst_0020',36,1);
%load '/SAS007/sz6414/IOP8/Goddard/figure/rain/m_e18const_all3/acci_16021608fulldomain.mat';
%load '/SAS009/sz6414/201706/Goddard/figure/rain/17060100_iSPPT_MP/acci_01180200fulldomain.mat';
load '/SAS009/sz6414/201706/Goddard/figure/rain/17060100_iSPPT_PBL/acci_01180200fulldomain.mat';
%load '/SAS009/sz6414/201706/Goddard/figure/rain/17060100/acci_01180200fulldomain.mat';
%expri='CTRL';
expri='PBL';
%%
 tresh=[30 50 80 100];
for tri=tresh;
        s_tresh=num2str(tri);
        number=zeros(yl,xl);   
        for k=1:yl
        for l=1:xl
         for i=1:memsize;
          if (acci{i}(k,l)>=tri );
          number(k,l)=number(k,l)+1;
          end
         end
        end
        end
        number=number*100/memsize;
        number(number+1==1)=NaN;
       
   %---------plot-----------------------------
         pmin=double(min(min(number)));  if pmin<L(1); L2=[pmin,L]; else L2=[L(1) L]; end
   
      figure('position',[100 500 600 500])
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')
      [~, hp]=m_contourf(x,y,number,L2);   set(hp,'linestyle','none');
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:130,'ytick',17:45); 
      m_gshhs_h('color','k','LineWidth',0.8);
      %m_coast('color','k');
        %hc=colorbar;   colormap(cmap);    set(hc,'fontsize',13);  caxis([0 100])   
      cm=colormap(cmap);   caxis([L2(1) L(length(L))])  
      hc=Recolor_contourf(hp,cm,L,'vert');  set(hc,'fontsize',13,'LineWidth',1)

        
      tit=[expri,'  PQPF  (',s_tresh,'mm)'];
      title(tit,'fontsize',16,'FontWeight','bold')
      outfile=['PQPF_',expri,'_',s_tresh,'.m'];
%       
      set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf']) 
      system(['convert -trim -density 350 ',outfile,'.pdf -quality 100 ',outfile,'.png']);
      system(['rm ',[outfile,'.pdf']]);   
%          
end
