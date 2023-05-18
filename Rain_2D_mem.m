clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')
addpath('colorbar/')

saveid=0;

member=[50]; sthr=[6];  accuh=8;  s_min='00';
%
expri='Hagibis01kme06';
year='2019'; month='10'; stday=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Rainfall';   fignam='rain_'; unit='mm';
%
plon=[134 144]; plat=[30 38];
%
load('colormap/colormap_rain.mat');  cmap=colormap_rain;
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%
L=[  1   2   6  10  15  20  30  40  50  70  90 110 130 150 200 300];
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
       hr=(j-1)*ai+ti;   s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');
       %----read-----
       infile= [indir,'/',s_mem,'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
       rain0{j} = ncread(infile,'rain');  
      end %j=1:2
      rain=double(rain0{2}-rain0{1}); 
      %
      lon = double(ncread(infile,'lon'));
      lat = double(ncread(infile,'lat'));    
      %  
      %---plot---
      plotvar=rain;
      pmin=double(min(min(plotvar)));   if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end     
      %
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
      [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
           
      %---grids and coast lines
      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  % m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',0.8,'color','k')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',130:2:150,'ytick',25:2:50); 
      %      
      tit={[titnam,'  (mem ',num2str(mem,'%.4d'),')'];[month,'/',s_date,' ',s_sth,s_min,'-',s_edh,s_min]};
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
      outfile=[outdir,'/',fignam,'mem',s_mem,'_',month,s_date,'_',s_sth,s_min,'_',num2str(ai),'h'];
      if saveid==1
        print(hf,'-dpng',[outfile,'.png']) 
        system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
      end
      %--
    end %mem
  end % accuh
end % hr

