clear
close all

saveid=1;

pltensize=1000;    
randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members
%
pltrng=[1  37];  pltint=12; expri='Hagibis05kme01'; infilename='201910101800';%hagibis


pltime=pltrng(1):pltint:pltrng(end);
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Similarity between'];   fignam=[expri,'_Simi_'];
%
ntime=length(pltime);
%%    
%---read ensemble
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%
for imem1=1:pltensize     
  infile=[indir,'/',num2str(member(imem1),'%.4d'),'/',infilename,'.nc'];      
  if imem1==1
    lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));  plev=double(ncread(infile,'lev'));
    data_time = (ncread(infile,'time'));  
    [nx, ny]=size(lon);  %ntime=length(data_time); 
    nlev=length(plev);
    u0=zeros(nx,ny,nlev,pltensize,ntime);  
    v0=zeros(nx,ny,nlev,pltensize,ntime); 
    T0=zeros(nx,ny,nlev,pltensize,ntime); 
    qv0=zeros(nx,ny,nlev,pltensize,ntime); 
  end  
  u0(:,:,:,imem1,:) = ncread(infile,'u',[1 1 1 pltrng(1)],[Inf Inf Inf ntime],[1 1 1 pltint]); 
  v0(:,:,:,imem1,:) = ncread(infile,'v',[1 1 1 pltrng(1)],[Inf Inf Inf ntime],[1 1 1 pltint]);
  T0(:,:,:,imem1,:) = ncread(infile,'t',[1 1 1 pltrng(1)],[Inf Inf Inf ntime],[1 1 1 pltint]);
  qv0(:,:,:,imem1,:) = ncread(infile,'qv',[1 1 1 pltrng(1)],[Inf Inf Inf ntime],[1 1 1 pltint]);
   
  if mod(imem1,50)==0; disp([num2str(imem1),'mem done']); end
end  %imem
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime));
disp('Done of reading files')
%%
 idifx=53; nx1=nx-idifx*2; ny1=ny-idifx*2;
 dP = plev(1:end-1)-plev(2:end); 
 dPm=repmat(reshape(dP,1,1,nlev-1),nx1,ny1,1);
 %%
inrprdc2=zeros(pltensize,pltensize,ntime);
for ti=1:ntime
  umean =  mean(u0(:,:,:,:,ti),4);
  vmean = mean(v0(:,:,:,:,ti),4);
  Tmean = mean(T0(:,:,:,:,ti),4);
  qvmean = mean(qv0(:,:,:,:,ti),4);
u=u0(:,:,:,:,ti);v=v0(:,:,:,:,ti);T=T0(:,:,:,:,ti);qv=qv0(:,:,:,:,ti);
up0=u-repmat(umean,1,1,1,pltensize);
vp0=v-repmat(vmean,1,1,1,pltensize);
Tp0=T-repmat(Tmean,1,1,1,pltensize);
qvp0=qv-repmat(qvmean,1,1,1,pltensize);
%
inrprdc=zeros(pltensize,pltensize);
imem1=1;
  for imem2=imem1:pltensize
    
  up1=up0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);up2=up0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
  vp1=vp0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);vp2=vp0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
  Tp1=Tp0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);Tp2=Tp0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
  qvp1=qvp0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);qvp2=qvp0(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
  
  norm1=cal_norm(up1,up1,vp1,vp1,Tp1,Tp1,qvp1,qvp1,dPm);
  norm2=cal_norm(up2,up2,vp2,vp2,Tp2,Tp2,qvp2,qvp2,dPm);
  norm12=cal_norm(up1,up2,vp1,vp2,Tp1,Tp2,qvp1,qvp2,dPm);
  
  inrprdc(imem1,imem2)=norm12/norm1.^0.5/norm2.^0.5;
    
  if mod(imem2,200)==0; disp([num2str(imem2),'mem done']); end
  end

tmp=triu(inrprdc,1)';
inrprdc=inrprdc+tmp;
%
inrprdc2(:,:,ti)=inrprdc;
disp([num2str(ti),'th time done']);
end
%%
% figure
% imagesc(inrprdc)
% colormap(jet)
% caxis([-1 1])
%
load('colormap/colormap_ncl.mat');cmap=colormap_ncl;
BCnum=50;
%%
theta=squeeze(real(acos(inrprdc2(:,1,:))));
pltx=cos(theta);  plty=sin(theta);
%
hf=figure('Position',[100 100 900 630]);
% line([-1 1]*ntime,[0 0],'color','k','linewidth',1.5); line([0 0],[1 -1]*ntime,'color','k','linewidth',1.5)
% hold on
for ti=ntime:-1:1
  pltx_ti=pltx(:,ti)*ti;  plty_ti=plty(:,ti)*ti;
% for ibc=1:2:50%[1 13 25 37 49]
  for ibc=1:8:50%[1 13 25 37 49]
    for imem=ibc:BCnum:pltensize
    plot(pltx_ti(imem),plty_ti(imem),'o','markerfacecolor',cmap(ibc*4+15,:),'markeredgecolor','k','markersize',8); hold on
    line([0 pltx_ti(imem)],[0 plty_ti(imem)],'color',cmap(ibc*4+15,:))
    % pair of sigular vectors
    plot(pltx_ti(imem+1),plty_ti(imem+1),'o','markerfacecolor',cmap(ibc*4+25,:),'markeredgecolor','k','markersize',8); hold on
    line([0 pltx_ti(imem+1)],[0 plty_ti(imem+1)],'color',cmap(ibc*4+25,:))
    drawnow
    end %imem
  end %ibc
end %ti
set(gca,'xlim',[min(pltx(:)) max(pltx(:))]*ntime,'ylim',[min(plty(:)) max(plty(:))]*ntime)
set(gca,'fontsize',16,'linewidth',1.2,'Box','on') 
grid on
%%
tit={[titnam,' M',num2str(imem1),' and others'];...
    [datestr(pltdate(1),'mm/dd HHMM-'),datestr(pltdate(end),'mm/dd HHMM '),'every ',num2str(pltint),'h']};   
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),datestr(pltdate(1),'_ddHH'),datestr(pltdate(end),'_ddHH_'),num2str(ntime),'t'];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
