clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

tint=3;
pltensize=20; pltime=1:tint:24;
randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members

%  expri='Hagibis05kme01'; infilename='201910101800';%hagibis
expri='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
% expri='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expri='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
%
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  PSEA spread spectra'];   fignam=[expri,'_PmslSprdSpectr_'];
%---
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%---
%%
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    pmsl0=zeros(nx,ny,ntime,pltensize);
  end  
  if isfile(infile) 
    pmsl0(:,:,:,imem) = ncread(infile,'pmsl');
  else
    pmsl0(:,:,:,imem) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end    
end
% disp('finished reading files')
%%
cenx=ceil((nx+1)/2);  ceny=ceil((ny+1)/2);    % position of mean value after shfit
[xii, yii]=meshgrid((1:ny)-ceny,(1:nx)-cenx);   
nk = (xii.^2+yii.^2 ).^0.5;                   % distant to the center
nk2=round(nk); 
%%
for ti=pltime
  
  ensmemb=squeeze(pmsl0(:,:,ti,:));
  ensmean=mean(ensmemb,3);
  enspert=ensmemb-repmat(ensmean,1,1,pltensize);
  
  spectr2D=0;
  for imem=1:pltensize 
    pertfft=fft2(squeeze(enspert(:,:,imem)));
    spectr2D = spectr2D + (abs(pertfft).^2)/nx/ny ; 
  end
  spectrshi2=fftshift(spectr2D/pltensize);
  for ki=1:max(nk2(:))   
    spetrkh(ki,ti)=sum(spectrshi2(nk2==ki));   % sum of different kx, ky to kh bin
  end
  
%   sprd=std(pmsl0(:,:,ti,:),0,4,'omitnan'); 
%   sprdfft=fft2(sprd);
%   spectr2D = (abs(sprdfft).^2)/nx/ny ; 
%   spectrshi=fftshift(spectr2D);
%   for ki=1:max(nk2(:))   
%     spetr_kh(ki)=sum(spectrshi(nk2==ki));   % sum of different kx, ky to kh bin
%   end
  
end %ti
%%
% plotime=[2 7 13 16 17 18 19 20 21 22 23 25 31 37 42];
load('colormap/colormap_ncl.mat')
col2=colormap_ncl(25:floor(length(colormap_ncl)/length(pltime))-1:end,:);

hf=figure('position',[100 55 940 660]) ;
n=0;
for ti=pltime
  n=n+1;
plot(spetrkh(:,ti),'LineWidth',3,'LineStyle','-','color',col2(n,:)); hold on

pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
 lgnd{n}=datestr(pltdate,'HHMM');
end
legend(lgnd,'Box','off','Interpreter','none','fontsize',15,'Location','BestOutside')

xlim=[1 min(nx,ny)];  ylim=[3e-5 5e5];

grids=5;
%---first axis---
set(gca,'YScale','log','XScale','log','XLim',xlim,'Linewidth',1.2,'fontsize',16)
set(gca,'Ylim',ylim)
xlabel('wavenumber'); ylabel('J kg^-^1')
%---second axis---
ax1=gca; ax1_pos = ax1.Position; set(ax1,'Position',ax1_pos-[0 0 0 0.075])
box off
 ax1=gca; ax1_pos = ax1.Position;  %ax1_label=get(ax1,'XTick');  ax1_ylabel=get(ax1,'YTick');
 ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none','TickLength',[0.015 0.015]);
 set(ax2,'YScale','log','XScale','log','XLim',[1 min(nx,ny)]*grids,'XDir','reverse','Linewidth',1.2,'fontsize',15)
 set(ax2,'Ylim',ylim,'Yticklabel',[])
 xlabel(ax2,'wavelength (km)'); ax2.XRuler.TickLabelGapOffset = 0.1;
%---
tit=[titnam,'  (rnd',num2str(randmem),')'];     
title(tit,'fontsize',18)
%---
outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),...
    '_t',num2str(pltime(1),'%.2d'),num2str(pltime(end),'%.2d'),'int',num2str(tint)   ];
if saveid==1
 print(hf,'-dpng',[outfile,'.png'])    
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end

%}
