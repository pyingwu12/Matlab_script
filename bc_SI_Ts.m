clear
close all

saveid=1;

pltensize=1000;    
randmem=0; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members
%
pltrng=[1  55];  pltint=12;
tint=1;%for x axis
expri='Hagibis05kme01'; infilename='201910101800';%hagibis
pltime=pltrng(1):pltint:pltrng(end);
BCsets=5:6:50; % use only odd number, interval must be even
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  Similarity between members'];   fignam=[expri,'_SimiTs_'];
%
ntime=length(pltime);
%%    
%---read ensemble
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end
%
inrprdc2=zeros(pltensize,pltensize,ntime);
for ti=1:ntime
  disp([num2str(ti),' th time doing...']);
  for imem=1:pltensize     
    infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];      
    if imem==1 %&& ti==1
      if ti==1
      lon = double(ncread(infile,'lon'));  lat = double(ncread(infile,'lat'));  plev=double(ncread(infile,'lev'));
      data_time = (ncread(infile,'time'));  
      [nx, ny]=size(lon);  %ntime=length(data_time); 
      nlev=length(plev);
      %---
       pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(pltime));
       idifx=53; nx1=nx-idifx*2; ny1=ny-idifx*2;
       dP = plev(1:end-1)-plev(2:end); 
       dPm=repmat(reshape(dP,1,1,nlev-1),nx1,ny1,1);
      end
      u=zeros(nx,ny,nlev,pltensize);  
      v=zeros(nx,ny,nlev,pltensize); 
      T=zeros(nx,ny,nlev,pltensize); 
      q=zeros(nx,ny,nlev,pltensize);    
    end  
    u(:,:,:,imem) = ncread(infile,'u',[1 1 1 pltime(ti)],[Inf Inf Inf 1],[1 1 1 1]); 
    v(:,:,:,imem) = ncread(infile,'v',[1 1 1 pltime(ti)],[Inf Inf Inf 1],[1 1 1 1]);
    T(:,:,:,imem) = ncread(infile,'t',[1 1 1 pltime(ti)],[Inf Inf Inf 1],[1 1 1 1]);
    q(:,:,:,imem) = ncread(infile,'qv',[1 1 1 pltime(ti)],[Inf Inf Inf 1],[1 1 1 1]);   
    if mod(imem,100)==0; disp([' ',num2str(imem),'mem done reading file']); end
  end  %imem
  
  umean = mean(u,4); up=u-repmat(umean,1,1,1,pltensize);
  vmean = mean(v,4); vp=v-repmat(vmean,1,1,1,pltensize);
  Tmean = mean(T,4); Tp=T-repmat(Tmean,1,1,1,pltensize);
  qmean = mean(q,4); qp=q-repmat(qmean,1,1,1,pltensize);
  clear u v T q
  %%
 %---- calculate inner produc
  inrprdc=zeros(pltensize,pltensize);
  for imem1=BCsets
  for imem2=1:pltensize      
    up1=up(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);up2=up(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
    vp1=vp(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);vp2=vp(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
    Tp1=Tp(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);Tp2=Tp(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);
    qvp1=qp(1+idifx:end-idifx,1+idifx:end-idifx,:,imem1);qvp2=qp(1+idifx:end-idifx,1+idifx:end-idifx,:,imem2);  
    %
    norm1=cal_norm(up1,up1,vp1,vp1,Tp1,Tp1,qvp1,qvp1,dPm);
    norm2=cal_norm(up2,up2,vp2,vp2,Tp2,Tp2,qvp2,qvp2,dPm);
    norm12=cal_norm(up1,up2,vp1,vp2,Tp1,Tp2,qvp1,qvp2,dPm);
    %--
    inrprdc(imem1,imem2)=norm12/norm1.^0.5/norm2.^0.5;
    
  %if mod(imem2,200)==0; disp([num2str(imem2),'mem done']); end
  end %mem2
  end %mem1
  
%   tmp=triu(inrprdc,1)'; inrprdc=inrprdc+tmp; % extend tringle to full matrix

  inrprdc2(:,:,ti)=inrprdc;
  %
%   disp(' Done calculating')
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
theta =  ( squeeze(real(acos(inrprdc2(BCsets,:,:))))/pi*180 );

hf=figure('Position',[100 100 800 530]);  
%
for ibc=1:length(BCsets)
        imem1=BCsets(ibc);

samBC= (theta(ibc,imem1+BCnum:BCnum:pltensize,:))  ;
difBC= (theta(ibc,imem1+1:BCnum:pltensize,:))  ;
 

plot(squeeze(mean(samBC,2)),'linewidth',2,'color',cmap(imem1*4+15,:)); hold on
plot(squeeze(mean(difBC,2)), 'linestyle','--','linewidth',2,'color',cmap(imem1*4+15,:)); 

theta2=squeeze(theta(ibc,:,:)); theta2(imem1:BCnum:pltensize,:)=NaN; theta2(imem1+1:BCnum:pltensize,ibc)=NaN;
plot( mean(theta2,1,'omitnan')  ,'linewidth',2,'color',[0.4 0.4 0.4])

end

set(gca,'fontsize',16,'linewidth',1.2,'Xlim',[1 ntime]) 

xlabel('Time (UTC)');   ylabel('\theta mean');
set(gca,'Xlim',[1 ntime],'xtick',1:tint:ntime,'Xticklabel',datestr(pltdate(1:tint:ntime),'mmm-dd HH'))
set(gca,'Ylim',[5 140],'ytick',10:20:150)
%%
tit=[titnam];
title(tit,'fontsize',18)

outfile=[outdir,'/',fignam,'rnd',num2str(randmem),'m',num2str(pltensize),datestr(pltdate(1),'_ddHH'),datestr(pltdate(end),'_ddHH_'),num2str(ntime),'t'];
if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
