clear 
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

iset = 1;  

pltrng=[1  25];  pltint=1; 
pltime=pltrng(1):pltint:pltrng(end);  tint=3;   

% fLb=1000; fLu=20000;
fLb=500; fLu=2000;
dx=5; dy=5;

expri='Hagibis05kme01'; infilename='201910101800';  idifx=53;  %hagibis

expsize=1000; BCnum=50; ensize=expsize/BCnum;

member_s=iset:BCnum:expsize;  % same BC
member_d=(iset-1)*ensize+1:iset*ensize; % diff BC
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  PSEA spread'];   fignam=[expri,'_PmslFiltSprd_'];
%--
ntime=length(pltime);

%%
for imem=1:ensize 
  infile=[indir,'/',num2str(member_d(imem),'%.4d'),'/',infilename,'.nc'];   
  if imem==1         
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));  
    [nx, ny]= size(lon);  

    vari0_d=zeros(nx,ny,ensize,ntime);
    vari0_s=zeros(nx,ny,ensize,ntime);
  end  
  vari0_d(:,:,imem,:) = ncread(infile,'pmsl',[1 1 pltrng(1)],[Inf Inf ntime],[1 1 pltint]);
end  
for imem=1:ensize 
  infile=[indir,'/',num2str(member_s(imem),'%.4d'),'/',infilename,'.nc'];    
  vari0_s(:,:,imem,:) = ncread(infile,'pmsl',[1 1 pltrng(1)],[Inf Inf ntime],[1 1 pltint]);
end
data_time = (ncread(infile,'time'));
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
% disp('finished reading files')
%%

mean_d=mean(vari0_d,3);
pert_d=vari0_d-repmat(mean_d,1,1,ensize,1);
mean_s=mean(vari0_s,3);
pert_s=vari0_s-repmat(mean_s,1,1,ensize,1);

% clear vari0_d vari0_s
%%
fLb=0.001; fLu=200;

pert_df=zeros(nx-idifx*2,ny-idifx*2,ensize,ntime);
pert_sf=zeros(nx-idifx*2,ny-idifx*2,ensize,ntime);
for ti=1:ntime
  for imem=1:ensize
     
     pert_df(:,:,imem,ti) = filter2d(pert_d(1+idifx:end-idifx,1+idifx:end-idifx,imem,ti),fLb,fLu,dx,dy);
     pert_sf(:,:,imem,ti) = filter2d(pert_s(1+idifx:end-idifx,1+idifx:end-idifx,imem,ti),fLb,fLu,dx,dy);
      
  end    
end
% pert_df=pert_d;
% pert_sf=pert_s;
%
[nx1, ny1, ~, ~]=size(pert_df);
 var_diff=   sum(pert_df.^2,3) / (ensize-1) ;  
 sprd_diff =  squeeze( ( sum( var_diff,[1 2]) /nx1/ny1).^0.5 );
 var_same=  sum(pert_sf.^2,3) / (ensize-1);  
 sprd_same =  squeeze( ( sum( var_same,[1 2]) /nx1/ny1).^0.5  );  
 
%
  
  %---plot
hf=figure('Position',[100 100 1000 630]);  
plot(sprd_same,'linewidth',2.5)
hold on
plot(sprd_diff,'linewidth',2.5)

legend('sameBC','diffBC','box','off','location','nw','fontsize',22)

set(gca,'fontsize',16,'linewidth',1.2,'Xlim',[1 ntime],'Ylim',[0 1]) 

% 
% hold on
% plot(squeeze((sprd_diff-sprd_same)./sprd_diff*100),'linewidth',2.5)
% plot(squeeze((sprd_same./sprd_diff*100)),'linewidth',2.5)
% set(gca,'fontsize',16,'linewidth',1.2,'Xlim',[1 pltime(end)]) 


% xlabel('Time (UTC)');   ylabel('Spread (mm)');
% set(gca,'fontsize',16,'linewidth',1.2) 
% set(gca,'Xlim',[1 pltime(end)],'xtick',1:tint:pltime(end),'Xticklabel',datestr(pltdate(1:tint:pltime(end)),'HH'))
% set(gca,'Ylim',[0 1.1])
%
  outfile=[outdir,'/',fignam,'m',num2str(ensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

%}