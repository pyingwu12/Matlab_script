clear
% close all

saveid=1;
%
pltensize=1000;  hr=16; minu=[00];
%
expnam='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='10-m wind speed (recenter)';   fignam=[expnam,'_windhist-recent_']; 
%---
load('H01km_center.mat')

%%
for ti=1:length(hr)
  s_date=num2str(day+fix(hr(ti)/24),'%2.2d');   s_hr=num2str(mod(hr(ti),24),'%2.2d'); 
  for tmi=minu
    s_min=num2str(tmi,'%.2d');    
%     ntrack=1+(ti-0)*6+(minu-10)/10;  %!!!!!!!!!!!!!!
    ntrack=1+(hr(ti)-0)*6+(tmi-0)/10;  %!!!!!!!!!!!!!!
    %
    % read ensemble
    tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       spd10_ens=zeros(pltensize,1);
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      
      cen_idx=typhoon_center(ntrack,member(imem));      
      [xp, yp]=ind2sub([nx ny],cen_idx);
      
      spd10_ens(imem)=double(u10(xp-100,yp+100).^2+v10(xp-100,yp+100).^2).^0.5;  

    end  %imem
    
%%
hist_Edge=0:35;
    %---plot
    plotvar=spd10_ens;
    hf=figure('Position',[100 100 1000 630]);
    histogram(plotvar,'Normalization','probability','BinEdges',hist_Edge); hold on
    
    %
    xlabel('Wind speed (m/s)'); ylabel('Frequency (%)')
  set(gca,'xlim',[hist_Edge(1) hist_Edge(end)],'ylim',[0 0.5],'fontsize',18,'linewidth',1.4) ;    
    yticklabels(yticks*100)
    %
    s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
    tit=[expnam,'  ',titnam,'  ',month,'/',s_date,' ',s_hr,s_min,' (',num2str(pltensize),' member)'];
    title(tit,'fontsize',18)
  
 outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

  end %min  
end %hr
