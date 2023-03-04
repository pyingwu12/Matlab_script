clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')
addpath('colorbar/')

saveid=0;

expsize=1000; randmem=randperm(expsize);
member=randmem(1:2); hr=[6]; minu=[00];
%
expri='Hagibis01km1000';
yyyy='2019'; mm='10'; dd=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; outdir='/data8/wu_py/Result_fig/Hagibis_1km';
titnam='Wind speed';   fignam='wind-spd_'; unit='m s^-^1';
%
plon=[134 144]; plat=[30 38];
%
load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2; 
cmap2=cmap*255;cmap2(:,4)=zeros(1,size(cmap2,1))+255;
%
L=[0.5 1 2 4 7 10 14 18 22 26 30 34 38];

%---
for ti=hr
  s_date=num2str(dd+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');
    for mem=member  
      s_mem=num2str(mem,'%.4d');
      %--infile---
      infile= [indir,'/',s_mem,'/',infilename,yyyy,mm,s_date,s_hr,s_min,'.nc'];
      %--read
      lon = double(ncread(infile,'lon'));
      lat = double(ncread(infile,'lat'));
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      pmsl = ncread(infile,'pmsl');
      %---
      spd10=double((u10.^2+v10.^2).^0.5);      
      
      %---plot---
      plotvar=spd10;
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
      title([titnam,'  ',mm,'/',s_date,'  ',s_hr,s_min,'  (mem ',num2str(mem,'%.4d'),')'],'fontsize',18)
      
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
      outfile=[outdir,'/',fignam,'mem',s_mem,'_',mm,s_date,'_',s_hr,s_min];
      if saveid==1
        print(hf,'-dpng',[outfile,'.png']) 
        system(['convert -trim ',outfile,'.png ',outfile,'.png']);         
      end
      %--
    end %mem
  end % minu
end % hr

