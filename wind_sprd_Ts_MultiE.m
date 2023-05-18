clear
% close all

saveid=0;

pltensize=50;  tint=3;
randmem=1; %0: plot member 1~pltensize; else:randomly choose <pltensize> members
kicksea=1;

expri={'Hagibis01kme02';'Hagibis01kme06';'H01MultiE0206'};
expnam={'GTOPO';'KTOPO';'COMPO'};
cexp=[0.3 0.75 0.9;  0.93 0.69 0.13;  0.46 0.67 0.19];
exptext='e02e06Kanto';
infilename='201910111800';
%
 expsize=600;
%
indir='/obs262_data01/wu_py/Experiments'; 
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Wind spread';   fignam=['wind-sprd-Ts_',exptext,'_'];
%
nexp=size(expri,1);
%
infile_hm='/obs262_data01/wu_py/Experiments/Hagibis01kme06/mfhm2.nc';
land = double(ncread(infile_hm,'landsea_mask'));
%---
if randmem~=0; tmp=randperm(expsize); member=tmp(1:pltensize); else; member=1:pltensize; end
%%
for ei=1:nexp  
  for imem=1:pltensize 
    infile=[indir,'/',expri{ei},'/',infilename,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
    if imem==1 && ei==1
     lon = double(ncread(infile,'lon'));
     lat = double(ncread(infile,'lat'));
     data_time = (ncread(infile,'time'));
     [nx, ny]=size(lon); ntime=length(data_time);   
     spd10_ens0=zeros(nx,ny,pltensize,ntime);
     sprd_ts=zeros(ntime,nexp);
    end  
    u10 = ncread(infile,'u10m');
    v10 = ncread(infile,'v10m');
    spd10_ens0(:,:,imem,:)=double(u10.^2+v10.^2).^0.5;     
  end
  disp([expri{ei},' read file end'])
  %---
  wind_sprd=squeeze(std(spd10_ens0,0,3,'omitnan')); 
%   %!!!
%   land(lon>141 | lon<138 | lat>37 | lat<34)=0;
%   %!!!
  if kicksea~=0; land2=repmat(land,1,1,ntime); wind_sprd(land2+1==1)=NaN;  end
  sprd_ts(:,ei)=squeeze(mean(wind_sprd,[1 2],'omitnan'));  
  disp([expri{ei},' finished'])
end
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
%%
%---plot
hf=figure('Position',[100 100 1000 630]);  
for ei=1:nexp
  plot(sprd_ts(:,ei),'linewidth',3.5,'color',cexp(ei,:)) ; hold on 
end
legend(expnam,'box','off','location','se','fontsize',27,'FontName','Monospaced')
%---
xlabel('Time (UTC)');   ylabel('Spread (m/s)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:end),'HH'))
% set(gca,'Ylim',[0.9 1.7])
%---date tick
%   yl=get(gca,'ylim');  text(0,yl(1)-3,[mm,'/',s_date],'fontsize',16)
%---
tit=[titnam,'  (',num2str(pltensize),'mem, ','rnd',num2str(randmem),', kick',num2str(kicksea),')'];
title(tit,'fontsize',18)
%---
outfile=[outdir,'/',fignam,'kick',num2str(kicksea),'_m',num2str(pltensize),'rnd',num2str(randmem)];
if saveid~=0
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
