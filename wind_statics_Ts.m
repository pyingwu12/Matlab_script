% clear
% close all

saveid=0;

pltensize=10;  

xp=656; yp=683; % 1km 1101*1201; (139.6, 35.2), near Haneda

randmem=0; %0: plot member 1~pltensize; else:randomly choose <pltensize> members

expri='Hagibis01kme01';
sth=5; lenh=10; minu=0;   tint=1;
%
expsize=1000;
yyyy='2019'; mm='10'; stday=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri]; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Wind speed';   fignam=[expri,'_wind-Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;
%---
spd10_ens=zeros(ntime,pltensize);
%%
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
nti=0;
for ti=1:lenh    
  hr=sth+ti-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for tmi=minu
    nti=nti+1;   s_min=num2str(tmi,'%.2d');
    for imem=1:pltensize 
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,yyyy,mm,s_date,s_hr,s_min,'.nc'];
    if imem==1 && nti==nti
     lon = double(ncread(infile,'lon'));
     lat = double(ncread(infile,'lat'));  
    end

      u10 = ncread(infile,'u10m');  v10 = ncread(infile,'v10m');
      spd_2d=double(u10.^2+v10.^2).^0.5;            
      spd10_ens(nti,imem)=spd_2d(xp,yp);
      
    end
  end
end

%%
%
  %---plot
  hf=figure('Position',[100 100 1000 630]);
  
  %---wind speed
 
   
  plot(spd10_ens,'linewidth',1.5,'color',[0.3,0.745,0.933]);  hold on

  plot(median(spd10_ens,2),'linewidth',2,'color',[0 0.4 0.7])
  plot(mean(spd10_ens,2),'linewidth',2,'color',[0 0 0],'linestyle','--')
  
  plot(quantile(spd10_ens,0.9,2),'linewidth',1,'color',[0 0.3 0.6],'linestyle','--')
  plot(quantile(spd10_ens,0.1,2),'linewidth',1,'color',[0 0.3 0.6],'linestyle','--')
  
  plot(mean(spd10_ens,2)-2*std(spd10_ens,0,2),'linewidth',2,'color',[0.8 0.2 0.3],'linestyle','--')
  plot(mean(spd10_ens,2)+2*std(spd10_ens,0,2),'linewidth',2,'color',[0.8 0.2 0.3],'linestyle','--')

  areaplt(:,1)=[1:ntime,ntime:-1:1];
  areaplt(:,2)=[quantile(spd10_ens,0.25,2)', fliplr(quantile(spd10_ens,0.75,2)')];  
  patch('Faces',1:ntime*2,'Vertices',areaplt,'FaceColor',[0 0.4 0.7],'FaceAlpha',.3,'edgecolor','none');

  
  %---
  xlabel('Time (UTC)');  ylabel('Speed (m/s)');
  set(gca,'fontsize',16,'linewidth',1.2)
  set(gca,'Ylim',[0 35],'YTick',0:5:40)
  set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'Xticklabel',sth:tint:sth+lenh-1)

  yl=get(gca,'ylim');  text(0.5,yl(1)-(yl(2)-yl(1))*0.08,[mm,'/',s_date],'fontsize',16)
  %---
  %   
  s_lon=num2str(lon(xp,yp),'%.1f');   s_lat=num2str(lat(xp,yp),'%.1f');
  tit=['10-m wind speed at (',s_lon,', ',s_lat,')  /  ',num2str(pltensize),' member'];
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize),'_x',num2str(xp),'y',num2str(yp)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
