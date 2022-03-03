% function DTEterm_2_cloudratio_multi(plotidx,ploterm,rang)

% calculate DTE mean over time
% P.Y. Wu @ 2021.03.31

close all; 
clear;  ploterm='LH'; rang=25;
ccc=':';

expri1={'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';'TWIN013Pr001qv062221';'TWIN022Pr001qv062221';
       'TWIN025Pr001qv062221';'TWIN019Pr001qv062221';'TWIN024Pr001qv062221';
       'TWIN021Pr001qv062221';'TWIN003Pr001qv062221';'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';'TWIN016Pr001qv062221';'TWIN018Pr001qv062221'
        };

expri2={'TWIN001B';...
        'TWIN017B';'TWIN013B';'TWIN022B';
        'TWIN025B';'TWIN019B';'TWIN024B';
        'TWIN021B';'TWIN003B';'TWIN020B';       
        'TWIN023B';'TWIN016B';'TWIN018B'
        };  


exptext='all';
%----
hydlim1=rang^2*pi*0.005;   s_hydlim1='005';
hydlim2=rang^2*pi*0.3;  s_hydlim2='30';
cloudhyd=0.005;
%topo_locx=75; topo_locy=100;
%
stday=22;   hrs=[23 24 25 26 27];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';

%
nexp=size(expri1,1); 

DTE_sum_log=zeros(nexp,1); KE_sum_log=zeros(nexp,1); ThE_sum_log=zeros(nexp,1); LH_sum_log=zeros(nexp,1);
npi=zeros(nexp,1);

%---plot
for ei=1:nexp  
    cldgnum2=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
     s_min=num2str(tmi,'%.2d');
      %---infile 1---
      infile1=[indir,'/',expri1{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      %---infile 2---
      infile2=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_date,'_',s_hr,ccc,s_min,ccc,'00'];
      hgt = ncread(infile2,'HGT');
      qr = double(ncread(infile2,'QRAIN'));   
      qc = double(ncread(infile2,'QCLOUD'));
      qg = double(ncread(infile2,'QGRAUP'));  
      qs = double(ncread(infile2,'QSNOW'));
      qi = double(ncread(infile2,'QICE')); 
      hyd2D = sum(qr+qc+qg+qs+qi,3);       
      
      [nx, ny]=size(hyd2D);     
      
      %---calculate distance to the topography top or max hyd---
      [maxval, maxloc]=max(hyd2D);  [~, ceny]=max(maxval);  cenx=maxloc(ceny);  % find maximum of hyd
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;
      cldgnum=length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang));  % cloud grid numbers in the specific range 
      
%---------------- 
      if cldgnum >= hydlim1 && cldgnum <= hydlim2 
        
        [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2); 
        dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
        dPall = P.f2(:,:,end)-P.f2(:,:,1);
        dPm = dP./repmat(dPall,1,1,size(dP,3)); 
        %---
         DTE3D = KE + ThE + LH ;
         %
         DTE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + Ps;
         KE2D = sum(dPm.*KE(:,:,1:end-1),3);
         ThE2D = sum(dPm.*ThE(:,:,1:end-1),3);
         LH2D = sum(dPm.*LH(:,:,1:end-1),3);
            
        DTE_2Dm= mean(DTE2D(dis2topo<=rang)) ;
        KE_2Dm= mean(KE2D(dis2topo<=rang)) ;
        ThE_2Dm= mean(ThE2D(dis2topo<=rang)) ;
        LH_2Dm= mean(LH2D(dis2topo<=rang)) ;
        
   
        DTE_sum_log(ei)=DTE_sum_log(ei)+log10( DTE_2Dm );
        KE_sum_log(ei)=KE_sum_log(ei)+log10( KE_2Dm );
        ThE_sum_log(ei)=ThE_sum_log(ei)+log10( ThE_2Dm );
        LH_sum_log(ei)=LH_sum_log(ei)+log10( LH_2Dm );
        
        
        npi(ei)=npi(ei)+1;
        disp([expri2{ei},'  ',s_hr,s_min,'+',num2str(npi(ei))])
        
      elseif cldgnum > hydlim2          
         break       
      end % if cnum > hydlim1 
      
    end % tmi
    if cldgnum > hydlim2; break; end
%     disp([s_hr,s_min,' done'])
  end %ti  
%   disp([expri2{ei},' done'])
end %ei

%%
DTE_mean_log=DTE_sum_log./npi;
KE_mean_log=KE_sum_log./npi;
ThE_mean_log=ThE_sum_log./npi;
LH_mean_log=LH_sum_log./npi;

plotDTE(1,3)=DTE_mean_log(1);  plotDTE(1,1:2)=[DTE_mean_log(1) DTE_mean_log(1)];
plotKE(1,3)=KE_mean_log(1);   plotKE(1,1:2)=[KE_mean_log(1) KE_mean_log(1)];
plotThE(1,3)=ThE_mean_log(1);  plotThE(1,1:2)=[ThE_mean_log(1) ThE_mean_log(1)];
plotLH(1,3)=LH_mean_log(1);   plotLH(1,1:2)=[LH_mean_log(1) LH_mean_log(1)];

n=1;
for h=2:5
  for v=1:3
    n=n+1;
    plotDTE(h,v)=DTE_mean_log(n);
    plotKE(h,v)=KE_mean_log(n);
    plotThE(h,v)=ThE_mean_log(n);
    plotLH(h,v)=LH_mean_log(n);    
   end
end
%%
load('colormap/colormap_hot20.mat')
cmap=colormap_hot20([1 2 3 4 5 6 8 9 10 11 12 13 14 20],:);
% cmap=colormap_hot20([1   3   5   8   10    12    14],:);
%%
close all

plotid={'DTE','KE','ThE','LH'};

for pi=1:4
  hf=figure('Position',[100 300 700 600]);
  eval(['plotvar=plot',plotid{pi},';'])
  imagesc(10.^plotvar)
  hc=colorbar('Ytick',[],'linewidth',1.5,'fontsize',16);
%   set(hc,'Ytick',[0.01 0.02 0.04 0.05 0.06 0.11 0.31 0.68])
  colormap(cmap)
  set(gca,'ColorScale','log','linewidth',2,'fontsize',18)
  set(gca,'xtick',[1 2 3],'xticklabel',{'V05','V10','V20'},'ytick',[1 2 3 4 5],'yticklabel',{'FLAT','H05','H075','H10','H20'})
  title(plotid{pi},'fontsize',23)
  for h=1:5
     for v=1:3
       if h<=2 && v>=3; textcol='k';  else;  textcol='w'; end
       
       text(v,h,num2str(10.^plotvar(h,v),'%.4f'),'HorizontalAlignment','center','color',textcol,'fontsize',22,'FontWeight','bold')
     end
  end
  
  fignam=[plotid{pi},'_timean_',exptext,'_'];  
  s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
  outfile=[outdir,'/',fignam,mon,num2str(stday),'_',num2str(length(hrs)),'hrs',s_sth,s_edh,'_',num2str(length(minu)),'min',...
       num2str(minu(1),'%.2d'),num2str(minu(end)),'_r',num2str(rang),'_hydlim',s_hydlim1,s_hydlim2];
%    outfile=[outfile,'_3'];
  print(hf,'-dpng',[outfile,'.png'])
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end