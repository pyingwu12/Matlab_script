clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

expsize=1000; 

refsize=1000;
% cmprsize=[10 18 32 56 100 178 316 562 997];
cmprsize=[10 32 100 316 997];
nbost=1;
    
expri0={'Hagibis05kme01';'Hagibis05kme02'};  nexp=size(expri0,1);
cexp=[0,0.447,0.741; 0.85,0.325,0.098];

% pltime=[28 31 34 37 40];  thresholds=[5 10 15 20 25]; 
pltime=[31 34];  thresholds=[5 10]; 


infilename='201910101800';    idifx=53; %hagibis05
%
indir='/obs262_data01/wu_py/Experiments/';  outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam='Wind prob. diff';   fignam='wind-prob-SamErr_';  
%%
%---read ensemble
  hf=figure('Position',[100 100 900 600]);

for ti=pltime  
      
  rmsd=zeros(length(cmprsize),nbost,length(thresholds),nexp); 
  bias=zeros(length(cmprsize),nbost,length(thresholds),nexp);
  for iexp=1:nexp 
    expri=expri0{iexp};
      
    for imem=1:expsize     
     infile=[indir,expri,'/',infilename,'/',num2str(imem,'%.4d'),'/',infilename,'.nc'];      
     if imem==1 && iexp==1
     data_time = (ncread(infile,'time'));    [nx, ny]=size(ncread(infile,'lat')); 
     pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time(ti));
     spd10_ens0=zeros(nx,ny,expsize);      
     end  
     u10 = ncread(infile,'u10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
     v10 = ncread(infile,'v10m',[1 1 ti],[Inf Inf 1],[1 1 1]);
     spd10_ens0(:,:,imem)=double(u10.^2+v10.^2).^0.5;  
%    if mod(imem,100)==0; disp(['Member ',num2str(imem),' done']); end
    end  %imem
    disp('end read files')
    %%
    spd=spd10_ens0(idifx:end-idifx,idifx:end-idifx,:);  
    [nx1, ny1, ~]=size(spd);
    %---probability for different thresholds
    for thi=1:length(thresholds)
    proRef=zeros(nx1,ny1); 
    for i=1:nx1
      for j=1:ny1
        proRef(i,j)=length(find(spd(i,j,1:refsize)>=thresholds(thi) ));
      end
    end
    proRef=proRef/refsize;  
    disp('end calculate proRef')
    %--------    
    for isz=1:length(cmprsize)
      for k=1:nbost
        ensz=cmprsize(isz);
        if k==1;  member=1:ensz; else; tmp=randperm(expsize); member=tmp(1:ensz);  end            
        pro=zeros(nx1,ny1);   
        for i=1:nx1
        for j=1:ny1
        pro(i,j)=length(find(spd(i,j,member)>=thresholds(thi)));
        end
        end
        pro=pro/ensz;
        rmsd(isz,k,thi,iexp)=sqrt( mean((pro-proRef).^2,'all') );
        bias(isz,k,thi,iexp)=mean( pro-proRef, 'all');
      end
    end 
    end
    disp(['exp',num2str(iexp),' done']) 
  end
  %%  
  %---plot
  for iexp=1:nexp 
%    plot(cmprsize,rmsd(:,2:end,iexp),'linewidth',1.5,'color',cexp(iexp,:),'linestyle',':'); hold on
   plot(cmprsize,rmsd(:,1,iexp)./rmsd(1,1,iexp),'linewidth',2.5,'marker','.','markersize',30,'color',cexp(iexp,:)); hold on
  end
  
end % pltime
%%
%{
%   tmp=1./sqrt(cmprsize).*sqrt(cmprsize(1))*rmsd(1,1,2);
%  plot(cmprsize,tmp-tmp(end))
  
%   plot(cmprsize,1./sqrt(cmprsize)-1./sqrt(cmprsize(end)))
% set(gca,'fontsize',16,'linewidth',1.2,'xtick',1:length(ensizes)-1,'xticklabel',ensizes(2:end))
% set(gca,'fontsize',16,'linewidth',1.2,'xlim',[0 1000],'XDir','reverse','xscale','log')
set(gca,'fontsize',16,'linewidth',1.2,'xlim',[0 1000],'xscale','log')

xlabel('Number of members')
title('RMSD from the 1000-members results','fontsize',18)

outfile=[outdir,'/SmplErrWindProb_1km_1200_v3'];
   
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);
    
     %%
  hf=figure('Position',[100 100 900 600]);
  for iexp=1:nexp 
   plot(cmprsize,bias(:,2:end,iexp),'linewidth',1.5,'color',cexp(iexp,:));hold on
   plot(cmprsize,bias(:,1,iexp),'linewidth',2,'marker','.','markersize',30,'color',cexp(iexp,:)); 
  end 
  
set(gca,'fontsize',16,'linewidth',1.2,'xlim',[0 1000],'XDir','reverse','xscale','log')

xlabel('Number of members')
title('Bias from the 1000-members results','fontsize',18)

outfile=[outdir,'/SmplErrWindProb_1km_1200_v3'];
   
     print(hf,'-dpng',[outfile,'.png'])    
     system(['convert -trim ',outfile,'.png ',outfile,'.png']);   
%}