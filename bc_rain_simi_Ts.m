clear
% close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=0;

acch=3;

tint=3;

pltensize=20; pltime=4:25;
randmem=50; %0: plot member 1~pltensize; 50: members 1:50:1000; else:randomly choose <pltensize> members

%  expnam='Hagibis05kme01'; infilename='201910101800';%hagibis
% expnam='Nagasaki05km'; infilename='202108131200';%nagasaki 05 (Duc-san)
expnam='Kumagawa02km'; infilename='202007030900';%kumakawa 02 (Duc-san)
% expnam='Nagasaki02km'; infilename='202108131300'; %nagasaki 02 (Oizumi-san)
%
expsize=1000;  
%
indir=['/obs262_data01/wu_py/Experiments/',expnam,'/',infilename];
outdir=['/home/wu_py/labwind/Result_fig/',expnam];
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[expnam,'  Rain similarity'];   fignam=[expnam,'_RainSimiTs_'];
%
%--
%---
if randmem==0; member=1:pltensize;  elseif randmem==50; member=1:50:1000; 
else;  tmp=randperm(expsize); member=tmp(1:pltensize); end

%---
%%
member=1:50:1000; 
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    vari0=zeros(nx,ny,ntime,pltensize);
    pmsl=zeros(nx,ny,ntime,pltensize);
  end  
  if isfile(infile) 
    vari0(:,:,:,imem) = ncread(infile,'rain');
%     pmsl(:,:,:,imem) = ncread(infile,'pmsl');
  else
    vari0(:,:,:,imem) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end    
end


accu=vari0(:,:,1+acch:end,:)-vari0(:,:,1:end-acch,:);


sum_var_xi=sum(var(accu,0,[1 2]),4);
var_sum_xi=var(sum(accu,4),0,[1 2]);

simi_sameBC=squeeze(sum_var_xi./var_sum_xi);



member=1:20; 
for imem=1:pltensize 
  infile=[indir,'/',num2str(member(imem),'%.4d'),'/',infilename,'.nc'];   
  if imem==1
    lon = double(ncread(infile,'lon'));    lat = double(ncread(infile,'lat'));
    data_time = (ncread(infile,'time'));   
    [nx, ny]=size(lon); ntime=length(data_time);
    vari0=zeros(nx,ny,ntime,pltensize);
    pmsl=zeros(nx,ny,ntime,pltensize);
  end  
  if isfile(infile) 
    vari0(:,:,:,imem) = ncread(infile,'rain');
%     pmsl(:,:,:,imem) = ncread(infile,'pmsl');
  else
    vari0(:,:,:,imem) = NaN;
    disp(['member ',num2str(member(imem),'%.4d'),' file does''t exist'])
  end    
end

accu=vari0(:,:,1+acch:end,:)-vari0(:,:,1:end-acch,:);

sum_var_xi=sum(var(accu,0,[1 2]),4);
var_sum_xi=var(sum(accu,4),0,[1 2]);


simi_diffBC=squeeze(sum_var_xi./var_sum_xi);


pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
% disp('finished reading files')

%%
hf=figure('Position',[100 100 1000 630]);  

plot(simi_diffBC,'linewidth',2.5)
hold on
plot(simi_sameBC,'linewidth',2.5)

legend('diffBC','sameBC','box','off','location','nw','fontsize',22)


xlabel('Time (UTC)');   ylabel('Spread (mm)');
set(gca,'fontsize',16,'linewidth',1.2) 
set(gca,'Xlim',[1 25],'xtick',1:tint:25,'Xticklabel',datestr(pltdate(1:tint:25),'HH'))
set(gca,'Ylim',[0.05 0.17])

%---
  tit=[titnam,'  (',num2str(pltensize),' member)'];
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize)];

%%
% for ti=pltime  
%   sprd=std(vari0(:,:,ti,:)-vari0(:,:,ti-acch,:),0,4,'omitnan');  
%  
% 
% end %ti
% %}
