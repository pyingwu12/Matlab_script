clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

member=[1]; hr=[13]; minu=[00];
%
% expnam='e02nh01G';
expri='Hagibis01kme05';
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam=[expri,'  Wind speed'];   fignam0=[expri,'_wind-spd_']; unit='m s^-^1';
%
% plon=[134 144]; plat=[30 38];
% plon=[134.8 143.5]; plat=[32.3 38.5];  fignam=[expnam,'_wind-sprd_']; lo_int=135:5:144; la_int=30:5:37; % Japan center of Kanto
% plon=[135 144.5]; plat=[32 39]; fignam=[expnam,'_wind-sprd_Kantou']; lo_int=136:2:144; la_int=33:2:37; % wide Kantou area
plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam=[fignam0,'tokyobay_']; lo_int=134:2:145; la_int=31:2:40;
%
% load('colormap/colormap_wind2.mat') 
% cmap=colormap_wind2; 
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[0.5 1 2 4 6 9 12 15 18 21 25 30 35];

load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 8 9 11 12 14 ],:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 5 10 15 20 25 30];

infile_hm=['/obs262_data01/wu_py/Experiments/',expri,'/mfhm2.nc'];
land = double(ncread(infile_hm,'landsea_mask'));

%%
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');   s_hr=num2str(mod(ti,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');
    for mem=member  
      s_mem=num2str(mem,'%.4d');
      %--infile---
      infile= [indir,'/',s_mem,'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      %--read
      lon = double(ncread(infile,'lon'));
      lat = double(ncread(infile,'lat'));
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      pmsl = ncread(infile,'pmsl');
      %---
      spd10=double((u10.^2+v10.^2).^0.5);      
      %%
      %---plot---
      plotvar=spd10;
%       pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
    tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
    pmin=min(tmp);  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
      %%
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
      [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
      
      m_contour(lon,lat,land,[0.1 0.1],'linewidth',1.3,'color',[0.1 0.1 0.1],'linestyle','--')

      
      pltcnt=940:5:1015; colcnt=[0.3 0.3 0.3];
      [c,hdis]=m_contour(lon,lat,pmsl,pltcnt,'color',colcnt,'linewidth',2);                 
clabel(c,hdis,pltcnt,'color',colcnt,'fontsize',13,'LabelSpacing',800)   
        
      %---grids and coast lines
            m_contour(lon,lat,land,[0.1 0.1],'linewidth',1.3,'color',[0.1 0.1 0.1],'linestyle','--')
      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  % m_gshhs_h('save','gumby');
%       m_usercoast('gumby','linewidth',0.8,'color','k')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',25:2:50); 
      %      
      title({[titnam],[month,'/',s_date,'  ',s_hr,s_min,'  (mem ',num2str(mem,'%.4d'),')']},'fontsize',18)
      
      %---colorbar---
      fi=find(L>pmin,1);
      L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
      hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
      colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
      hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
      for idx = 1 : numel(hFills)
        hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
      end
      
      %---    
      outfile=[outdir,'/',fignam,'mem',s_mem,'_',month,s_date,'_',s_hr,s_min];
      if saveid==1
        print(hf,'-dpng',[outfile,'.png']) 
        system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
      end
      %--
    end %mem
  end % minu
end % hr

