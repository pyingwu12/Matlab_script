clear
close all

saveid=1;

pltensize=50; 

sth=0; lenh=14; minu=0:20:6;   tint=1;
%
expri='Hagibis01kme01';  expsize=1000;
yyyy='2019'; mm='10'; stday=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end

titnam='Sea level pressure';   fignam=[expri,'_pmsl-Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;
%---
% tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members 
member=1:pltensize;  %!!!!!!!!!!!!! 

%---
load('H01km_center.mat')

%--best track
%   infileo='/data8/wu_py/Data/Hagibis.txt';
%   obs=importdata(infileo);
% best_pre=[950 950 965 975];
%--

%%
nti=0; pmsl_ens=zeros(ntime,pltensize);
for ti=1:lenh    
  hr=sth+ti-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for tmi=minu
    nti=nti+1;   s_min=num2str(tmi,'%.2d');
    
    ntrack=1+(hr-0)*6+(tmi-0)/10;  %!!!!!!!!!!!!!!
    
    for imem=1:pltensize 
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,yyyy,mm,s_date,s_hr,s_min,'.nc'];
      if ~exist(infile,'file')       
        pmsl_ens(nti,imem)=NaN; continue;
      else
      pmsl = ncread(infile,'pmsl');
      pmsl_ens(nti,imem)=pmsl(typhoon_center(ntrack,imem));
      end
    end %imem
  end %tmi
disp([s_hr,s_min,' done'])
end
lon = double(ncread(infile,'lon'));
lat = double(ncread(infile,'lat'));        
%% normal plot
%{
  %---plot
  hf=figure('Position',[100 100 1000 630]);  
  %---wind speed
  plot(pmsl_ens,'linewidth',2,'color',[0.95 0.85 0.1],'linestyle','-','Marker','none') ; hold on 
%---mean
  plot(mean(pmsl_ens,2),'color',[0.8 0.7 0.05],'linewidth',2.3)
  %---best track
  plot(([1 7 13 19]-1)*nminu+1,[950 950 965 975],'ok','MarkerFaceColor','k','linestyle','-.','linewidth',1.5)
  
  %---
  xlabel('Time (UTC)');   ylabel('Pressure (hPa)');
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'Xticklabel',sth:tint:sth+lenh-1)
%---date tick
%   yl=get(gca,'ylim');  text(0,yl(1)-3,[mm,'/',s_date],'fontsize',16)

  %---
  tit=[titnam,'  (',num2str(pltensize),' member)'];
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
%}
%% separate color for different parameterization
  %---plot
  hf=figure('Position',[100 100 1000 630]);  
  %---wind speed
  plot(pmsl_ens(:,mod(member,50)>25),'linewidth',2,'color',[0.1 0.6 0.95],'linestyle','-','Marker','none') ; hold on
  plot(pmsl_ens(:,mod(member,50)<=25),'linewidth',2,'color',[0.95 0.6 0.1],'linestyle','--','Marker','none') ; hold on 

  %---mean
  plot(mean(pmsl_ens,2),'color',[0.1 0.1 0.1],'linewidth',3)
  %---best track
  plot(([1 7 13 19]-1)*nminu+1,[950 950 965 975],'ok','MarkerFaceColor','k','linestyle','-.','linewidth',1.5)
  
  %---
  xlabel('Time (UTC)');   ylabel('Pressure (hPa)');
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'Xticklabel',sth:tint:sth+lenh-1)
%---date tick
%   yl=get(gca,'ylim');  text(0,yl(1)-3,[mm,'/',s_date],'fontsize',16)

  %---
  tit=[titnam,'  (',num2str(pltensize),' member)'];
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,'m',num2str(pltensize),'_colored'];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
