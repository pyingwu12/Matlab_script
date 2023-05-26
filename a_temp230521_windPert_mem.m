clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

member=[101 300]; hr=[0]; minu=[0 10]; varinam='u10m';

ensize=50; %for calculate ensemble mean
%
expri='Hagibis01kme01'; year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Pert. of ',varinam];   fignam=[expri,'_',varinam,'Pert_'];  
%
 plon=[132 145 ]; plat=[28 40.5]; lo_int=130:5:148;  la_int=30:5:49; domtxt='1kmC';
%
infile_hm=['/obs262_data01/wu_py/Experiments/Hagibis01kme02/mfhm2.nc'];
land = double(ncread(infile_hm,'landsea_mask'));
%%
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');   s_hr=num2str(mod(ti,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');    
    %%
    vari_mean=0;
    for imem=1:ensize      
      infile= [indir,'/',num2str(imem,'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      vari0 = ncread(infile,varinam);
      vari_mean = vari_mean + vari0/ensize;
    end
    %%    
    for imem=member 
      s_mem=num2str(imem,'%.4d');
      infile= [indir,'/',s_mem,'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      %--read
      lon = double(ncread(infile,'lon'));      lat = double(ncread(infile,'lat'));
      vari_mem = ncread(infile,varinam); 
      pmsl = ncread(infile,'pmsl');      
      %---plot---
      plotvar=vari_mem-vari_mean;
%     tmp=plotvar(lon>=plon(1) & lon<=plon(2) & lat>=plat(1) & lat<=plat(2) );
%     pmin=min(tmp);  if pmin<L(1); L2=[pmin,L]; else; L2=[L(1) L]; end    
      %
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%       [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none');  hold on  
      [~, hp]=m_contourf(lon,lat,plotvar,20,'linestyle','none');  hold on  
      %
      colorbar('fontsize',15,'LineWidth',1.5);      
      caxis([-6 6])
      %
      %---plot pmsl contours
      pltcnt=940:10:1020; colcnt=[0.3 0.3 0.3];
      [c,hdis]=m_contour(lon,lat,pmsl,pltcnt,'color',colcnt,'linewidth',1);                 
%       clabel(c,hdis,pltcnt,'color',colcnt,'fontsize',13,'LabelSpacing',800)   
        
      %---grids and coast lines
      m_contour(lon,lat,land,[0.6 0.6],'linewidth',1,'color',[0.9 0.9 0.9],'linestyle','--')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',lo_int,'ytick',la_int); 

      % m_coast('color','k');
      % m_gshhs_h('color','k','LineWidth',0.8);  % m_gshhs_h('save','gumby');
%       m_usercoast('gumby','linewidth',0.8,'color','k')
      %      
      title({[titnam],[month,'/',s_date,'  ',s_hr,s_min,'  (mem ',num2str(imem,'%.4d'),')']},'fontsize',18)
      
%       %---colorbar---
%       fi=find(L>pmin,1);
%       L1=((1:length(L))*(diff(caxis)/(length(L)+1)))+min(caxis());
%       hc=colorbar('YTick',L1,'YTickLabel',L,'fontsize',15,'LineWidth',1.5);
%       colormap(cmap); title(hc,unit,'fontsize',15);  drawnow;  
%       hFills = hp.FacePrims;  % array of matlab.graphics.primitive.world.TriangleStrip objects
%       for idx = 1 : numel(hFills)
%         hFills(idx).ColorData=uint8(cmap2(idx+fi-1,:)');
%       end      
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