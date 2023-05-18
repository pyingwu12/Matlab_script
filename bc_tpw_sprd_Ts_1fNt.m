clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

pltensize=20;   tint=3; pltime=1:25;

% hf=figure('Position',[100 100 1000 630]);  
% expri='Hagibis05kme01'; infilename='201910101800';  idifx=53;  %hagibis
% expri='Nagasaki05km'; infilename='202108131200';  idifx=53;    %nagasaki 05 (Duc-san)
% expri='Nagasaki02km'; infilename='202108131300'; idifx=44;    %nagasaki 02 (Oizumi-san)
expri='Kumagawa02km'; infilename='202007030900'; idifx=58;    %kumakawa 02 (Duc-san)
%
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expri,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expri];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expri,'  TPW spread'];   fignam=[expri,'_TpwSprdTs_'];
%--
member1=21:40;  
member2=2:50:1000; 
%%
for imem=1:pltensize 
  infile=[indir,'/',num2str(member1(imem),'%.4d'),'/s',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    vari0_diff=zeros(nx,ny,ntime,pltensize);
    vari0_same=zeros(nx,ny,ntime,pltensize);
  end  
  vari0_diff(:,:,:,imem) = ncread(infile,'tpw');
end

for imem=1:pltensize 
  infile=[indir,'/',num2str(member2(imem),'%.4d'),'/s',infilename,'.nc'];    
  vari0_same(:,:,:,imem) = ncread(infile,'tpw');
end
pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);

% disp('finished reading files')
%%

vari1_same=vari0_same(1+idifx:end-idifx,1+idifx:end-idifx,pltime,:);
vari1_diff=vari0_diff(1+idifx:end-idifx,1+idifx:end-idifx,pltime,:);
[nx1, ny1, ntime1, ~]=size(vari1_same);

%   nrm_var_same= var(vari1_same,0,4)./ mean(vari1_same,4) ./ mean(vari1_same,4);  
%   nrm_sprd_same = ( sum( nrm_var_same,[1 2]) /nx1/ny1).^0.5 ;
%  
%   nrm_var_diff= var(vari1_diff,0,4)./ mean(vari1_diff,4) ./ mean(vari1_diff,4);  
%   nrm_sprd_diff = ( sum( nrm_var_diff,[1 2]) /nx1/ny1).^0.5 ;
  
  var_same= var(vari1_same,0,4);  
  sprd_same = ( sum( var_same,[1 2]) /nx1/ny1).^0.5;
%  
  var_diff= var(vari1_diff,0,4);  
  sprd_diff = ( sum( var_diff,[1 2]) /nx1/ny1).^0.5;

  
%---plot
% % hf=figure('Position',[100 100 1000 630]);  
% hold on
% % plot(squeeze(sprd_same./mean(vari1_same,[1 2 4])),'linewidth',2.5)
% plot(squeeze(sprd_same),'linewidth',2.5)
% % plot(squeeze(nrm_sprd_same),'linewidth',2.5)
% 
% % plot(squeeze(sprd_diff),'linewidth',2.5)
% set(gca,'fontsize',16,'linewidth',1.2,'Xlim',[1 pltime(end)]) 
% % legend('sameBC','diffBC','box','off','location','nw','fontsize',22)


% 
hold on
plot(squeeze((sprd_diff-sprd_same)./sprd_diff*100),'linewidth',2.5)
% plot(squeeze((sprd_same./sprd_diff*100)),'linewidth',2.5)
set(gca,'fontsize',16,'linewidth',1.2,'Xlim',[1 pltime(end)]) 


% xlabel('Time (UTC)');   ylabel('Spread (mm)');
% set(gca,'fontsize',16,'linewidth',1.2) 
% set(gca,'Xlim',[1 pltime(end)],'xtick',1:tint:pltime(end),'Xticklabel',datestr(pltdate(1:tint:pltime(end)),'HH'))
% set(gca,'Ylim',[0 1.1])
%
  outfile=[outdir,'/',fignam,'m',num2str(pltensize)];
  if saveid==1
   print(hf,'-dpng',[outfile,'.png'])    
   system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end

%}