clear
close all
addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;
  
experiments={'Hagibis05kme01';'Nagasaki05km';'Nagasaki02km';'Kumagawa02km'};
expnam={'Hagibis05km';'Nagasaki05km';'Nagasaki02km';'Kumagawa02km'};
infilenames=['201910101800';'202108131200';'202108131300';'202007030900'];
cexp0=[0.6 0.8 0.95; 0.96 0.7 0.5;  0.99 0.95 0.5;  0.8 0.7 0.91];
cexp=[0 0.447 0.741; 0.85 0.325 0.098;  0.929 0.694 0.125;  0.494 0.184 0.556];
idifxs=[53 53 44 58];

BCsets=1:50; 
nrmid=1;
variname='rain';  acch=1; pltime=1+acch:24+acch; 
% variname='tpw';  acch=0; pltime=1:24; 
% variname='pmsl';  acch=0; pltime=1:24; 

%
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
%
titnam=[variname,' spread'];   fignam=['BC_',variname,'SprdTs_'];
%---
% pltdate = datetime(infilename,'InputFormat','yyyyMMddHHmm') + minutes(data_time);
%
nexp=size(experiments,1);
ntime=length(pltime);
nset=length(BCsets);
%%
sprd_s=zeros(ntime,nexp,nset); sprd_d=zeros(ntime,nexp,nset);
for iset=1:nset
  for iexp=1:nexp   
  [sprd_s(:,iexp,iset), sprd_d(:,iexp,iset)]=bc_cal_sprd(experiments{iexp},infilenames(iexp,:),idifxs(iexp),...
        BCsets(iset),variname,acch,pltime,nrmid);
%     disp([experiments{iexp},' done'])
  end
disp (['set ',num2str(iset),' done'])
end %iset
%%
%---plot
% cexp0=[0.6 0.8 0.95; 0.96 0.7 0.5;  0.99 0.95 0.5;  0.8 0.7 0.91];
close all
plotexp=[1 3 4 2 ];
hf=figure('Position',[100 100 1100 530]);  
for  iexp=plotexp
%   h(iexp)=plot(squeeze(sprd_s(:,iexp,:)),'linewidth',2.5,'color',cexp(iexp,:));
%   for iset=1:iset
  plot(squeeze(sprd_s(:,iexp,:)),'linewidth',1.5,'color',cexp0(iexp,:),'linestyle',':');
  hold on
%   end
    h(iexp)=plot(squeeze(mean(sprd_s(:,iexp,:),3)),'linewidth',4,'color',cexp(iexp,:));

% plot(squeeze((sprd_d(:,iexp,:)-sprd_s(:,iexp,:))./sprd_d(:,iexp,:)*100),'linewidth',2.5,'color',cexp(iexp,:))
end
% for  iexp=1:nexp
%   h(iexp)=plot(squeeze(mean(sprd_s(:,iexp,:),3)),'linewidth',3,'color',cexp(iexp,:));
% end
legend(h,expnam,'box','off','location','bestout','fontsize',20)

if strcmp(variname,'rain')==1; titnam=[num2str(acch),'h ',variname,' spread']; end
tit=[titnam,'  (',num2str(nset),' BC sets, nrm',num2str(nrmid),')'];  title(tit,'fontsize',25)
%
set(gca,'fontsize',16,'linewidth',1.2,'Xlim',[1 ntime]) 
xlabel('FT (h)');   ylabel('Spread (normalized)');
%
outfile=[outdir,'/',fignam,'nrm',num2str(nrmid),'_',num2str(nset),'set'];
if saveid==1
 print(hf,'-dpng',[outfile,'.png'])    
 system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
%%
save(['bc_',variname,'_sprd_nrm',num2str(nrmid),'_',num2str(nset),'set.mat'],'sprd_s','sprd_d')
