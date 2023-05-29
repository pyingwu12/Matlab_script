clear
close all

saveid=1;

pltensize=100; 

sth=0; lenh=15; minu=0:10:50;   tint=1;
%
expri='Hagibis01kme01';  expsize=1000;
yyyy='2019'; mm='10'; stday=12;  infilename='sfc';
%
indir=['/obs262_data01/wu_py/Experiments/',expri];
outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end
titnam='Sea level pressure spread';   fignam=[expri,'_pmsl-sprd-Ts_'];
%
nminu=length(minu);  ntime=lenh*nminu;
%---
% tmp=randperm(expsize); member=tmp(1:pltensize);  %!!!!!!!!!!!!! random choose members 
member=1:pltensize;   %!!!!!!!!!!
%---

%%
nti=0;  pmsl_sprd=zeros(ntime,1); pmsl_sprd50=zeros(ntime,1); pmsl_sprd950=zeros(ntime,1);
for ti=1:lenh    
  hr=sth+ti-1;  s_date=num2str(stday+fix(hr/24),'%2.2d');   s_hr=num2str(mod(hr,24),'%2.2d'); 
  for tmi=minu
    nti=nti+1;   s_min=num2str(tmi,'%.2d');
        
    for imem=1:pltensize 
      infile= [indir,'/',num2str(member(imem),'%.4d'),'/',infilename,yyyy,mm,s_date,s_hr,s_min,'.nc'];
      if imem==1
          pmsl_ens=zeros(size(ncread(infile,'pmsl')));
      end
      pmsl_ens(:,:,imem)=ncread(infile,'pmsl');
    end %imem
    
    
   %---all 
   ensmean=repmat(mean(pmsl_ens,3),[1,1,pltensize]);
   enspert=pmsl_ens-ensmean;
   sprd=sqrt(sum(enspert.^2,3)./(pltensize-1));  
   pmsl_sprd(nti)=mean(sprd(:));   
   
   %---1~50
   clear ensmean enspert sprd
   ensmean=repmat(mean(pmsl_ens(:,:,member<=50),3),[1,1,50]);
   enspert=pmsl_ens(:,:,member<=50)-ensmean;
   sprd=sqrt(sum(enspert.^2,3)./(50-1));  
   pmsl_sprd50(nti)=mean(sprd(:));
   
   %---50~
   clear ensmean enspert sprd
   ensmean=repmat(mean(pmsl_ens(:,:,member>50),3),[1,1,pltensize-50]);
   enspert=pmsl_ens(:,:,member>50)-ensmean;
   sprd=sqrt(sum(enspert.^2,3)./((pltensize-50)-1));  
   pmsl_sprd950(nti)=mean(sprd(:));

  end %tmi
disp([s_hr,s_min,' done'])
end

%%
  %---plot
  hf=figure('Position',[100 100 1000 630]);  
  %---wind speed
  plot(pmsl_sprd,'linewidth',4,'color','k') ; hold on
  plot(pmsl_sprd50,'linewidth',3,'color',[ 0,0.447,0.741]) ;
  plot(pmsl_sprd950,'linewidth',3,'color',[0.85,0.325,0.098]) ;
  
  legend('all','1-50',['50-',num2str(pltensize)],'location','nw','fontsize',16,'box','off')
  
  %---
  xlabel('Time (UTC)');   ylabel('Spread (hPa)');
  set(gca,'fontsize',16,'linewidth',1.2) 
  set(gca,'Xlim',[1 ntime],'XTick',nminu*(tint-1)+1 : tint*nminu : ntime,'Xticklabel',sth:tint:sth+lenh-1)
%---date tick
%   yl=get(gca,'ylim');  text(0,yl(1)-3,[mm,'/',s_date],'fontsize',16)

  %---
  tit=[titnam,'  (',num2str(pltensize),' member)'];
  title(tit,'fontsize',18)
  %---
  outfile=[outdir,'/',fignam,num2str(lenh),'h_',num2str(nminu),'min'...
      ,'_m',num2str(pltensize)];
  if saveid~=0
    print(hf,'-dpng',[outfile,'.png'])    
    system(['convert -trim ',outfile,'.png ',outfile,'.png']);
  end
