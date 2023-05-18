clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

member=1;

randmem=0; %0: plot memberspecified by <member>; else:randomly choose <pltensize> members
pltsize=20; expsize=1000;
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); end
 
sthr=2:16;  accuh=1;  s_min='00';
%
expnam='Hagibis01kme01';
year='2019'; month='10'; stday=12;  infilename='sfc';

%
indir=['/obs262_data01/wu_py/Experiments/',expnam]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Wind speed & Ps';   fignam=[expnam,'_typhoon-wind_'];  unit='m s^-^1';
% titnam='Rainfall & Ps';   fignam=[expnam,'_typhoon-rain_'];  unit='mm';
%
plon=[134 144]; plat=[30 38];
%
% load('colormap/colormap_rain.mat');  cmap=colormap_rain;
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 250];
%
% load('colormap/colormap_wind2.mat') ;  cmap=colormap_wind2; 
% cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
% L=[0.5 1 2 4 6 9 12 15 18 21 25 30 35];
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 8 9 11 12 14 ],:); cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
L=[1 5 10 15 20 25 30];
%%
%---
for ti=sthr
  s_sth=num2str(mod(ti,24),'%2.2d');
  for ai=accuh
    s_edh=num2str(mod(ti+ai,24),'%2.2d'); 
    for mem=member  
      s_mem=num2str(mem,'%.4d');     
      %--infile---      
      for j=1:2
       hr=(j-1)*ai+ti-1;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
       %----read-----
       infile= [indir,'/',s_mem,'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
       rain0{j} = ncread(infile,'rain');  
       if j==2
        lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));         
        u10 = ncread(infile,'u10m');  v10 = ncread(infile,'v10m');
         spd10=double(u10(:,:).^2+v10(:,:).^2).^0.5; 
        pmsl = ncread(infile,'pmsl');
       end
      end %j=1:2
      rain=double(rain0{2}-rain0{1});      
      %%
      %---plot---
%       plotvar=rain;
      plotvar=spd10;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
      %
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
      [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
      %
      %---grids and coast lines
      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  % m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
      %---
      
      [c,hdis]=m_contour(lon,lat,pmsl,950:10:1010,'color',[0.3 0.3 0.3],'linewidth',2.3);   
      clabel(c,hdis,950:10:1010,'fontsize',12,'LabelSpacing',800)   

%       m_contour(lon,lat,spd10,[25 25],'color',[0.8 0.4 0.5],'linewidth',2.8);
      m_contour(lon,lat,rain,[30 100],'color',[0.6 0.1 0.95],'linewidth',2.5);
      %---
      tit={[titnam,'  ',month,'/',s_date,' ',s_sth,s_min];[num2str(ai),'-h rainfall','  (mem ',s_mem,')']};
      title(tit,'fontsize',18)
      
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
      outfile=[outdir,'/',fignam,month,s_date,'_',s_sth,s_min,'_',num2str(ai),'h_mem',num2str(mem)];
      if saveid==1
        print(hf,'-dpng',[outfile,'.png']) 
        system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
      end
      %--
    end %mem
  end % accuh
end % hr

