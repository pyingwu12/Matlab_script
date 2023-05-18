clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')
addpath('colorbar/')

saveid=1;
%
pltensize=1000;  hr=[11 12];  minu=[00];  pltspds=[15]; 
%
expnam='H01km';
expri='Hagibis01km1000';  expsize=1000;
year='2019'; month='10'; day=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
%outdir='/data8/wu_py/Result_fig';
titnam='Wind speed';   fignam=[expnam,'_wind-spagh_'];  
%
% plon=[134 144]; plat=[30 38];
    plon=[135.5 142.5]; plat=[33.5 37]; fignam=[fignam,'2_']; 
%---
for ti=hr
  s_date=num2str(day+fix(ti/24),'%2.2d');   s_hr=num2str(mod(ti,24),'%2.2d');  
  for tmi=minu
    s_min=num2str(tmi,'%.2d');    
    %
    % read ensemble
    tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members  
    for imem=1:pltensize     
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,year,month,s_date,s_hr,s_min,'.nc'];
      if imem==1
       lon = double(ncread(infile,'lon'));
       lat = double(ncread(infile,'lat'));
       [nx, ny]=size(lon);
       spd10_ens=zeros(nx,ny,pltensize);
      end  
      u10 = ncread(infile,'u10m');
      v10 = ncread(infile,'v10m');
      spd10_ens(:,:,imem)=double(u10(:,:).^2+v10(:,:).^2).^0.5;  
    end  %imem

    % probability for different thresholds
    for plti=pltspds      
%       wind_pro=zeros(nx,ny);   
%       for i=1:nx
%           for j=1:ny
%               wind_pro(i,j)=length(find(spd10_ens(i,j,:)>=plti));
%           end
%       end
%       wind_pro=wind_pro/pltensize*100;
%       wind_pro(wind_pro+1==1)=NaN;
      %
      %---plot
      %%
      hf=figure('Position',[100 100 800 630]);
      m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
%       [~, hp]=m_contourf(lon,lat,plotvar,L2,'linestyle','none'); hold on      
%       m_coast('color','k');
%       m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');
      m_usercoast('gumby','linewidth',1,'color',[0.1 0.1 0.1],'linestyle','--')
      m_grid('fontsize',12,'LineStyle','-.','LineWidth',0.8,'xtick',130:5:150,'ytick',25:5:50,'color',[0.3 0.3 0.3]); 
      %
      hold on
      for imem=1:pltensize     
       m_contour(lon,lat,spd10_ens(:,:,imem),[plti plti],'linewidth',0.8,'color',[1 0.8 0]);
      end    
      % ensemble mean
%       m_contour(lon,lat,mean(spd10_ens,3),[plti plti],'r','linewidth',2); 
%---
      tit={[titnam,' (',num2str(plti),' m/s)'];[month,'/',s_date,' ',s_hr,s_min,'  (',num2str(pltensize),' mem)']};
      title(tit,'fontsize',18)
      %
      %
      outfile=[outdir,'/',fignam,month,s_date,'_',s_hr,s_min,'_m',num2str(pltensize),'thrd',num2str(plti),];
      if saveid==1
       print(hf,'-dpng',[outfile,'.png'])    
       system(['convert -trim ',outfile,'.png ',outfile,'.png']);
      end
    end %thi
  end %min
end %hr
