
% P.Y. Wu @ 2021.04.24

% close all
clear;  exptext='0103'; ploterm='MDTE'; rang=25; cloudhyd=0.005;
ccc=':';

expri1={
    'TWIN001Pr001qv062221';...
       'TWIN017Pr001qv062221';  'TWIN022Pr001qv062221';
       'TWIN021Pr001qv062221';  'TWIN020Pr001qv062221';
       'TWIN023Pr001qv062221';  'TWIN018Pr001qv062221'
        };

expri2={
    'TWIN001B';...
        'TWIN017B';  'TWIN022B';
        'TWIN021B';  'TWIN020B';       
        'TWIN023B';  'TWIN018B'
        };    
   
expnam={ 'FLAT';
        'V05H05';  'V20H05';
        'V05H10';  'V20H10';
        'V05H20';  'V10H20';
        };
    
expmark={'s';        
         'o'; 'x';         
         '^'; '+';
         'p'; '*';
         };

% expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN003Pr001qv062221'};
% expri2={'TWIN001B';'TWIN013B';'TWIN003B'};    
% expnam={ 'FLAT';'V10H05';'TOPO'};
% expmark={'s';'o';'^'};

% expri1={'TWIN001Pr001qv062221';'TWIN013Pr001qv062221';'TWIN003Pr001qv062221';'TWIN016Pr001qv062221'};
% expri2={'TWIN001B';'TWIN013B';'TWIN003B';'TWIN016B'};    
% expnam={ 'FLAT';'V10H05';'TOPO';'V10H0'};
% expmark={'s';'o';'^';'p'};

%---
stday=22;   hrs=[23 24 25 26];  minu=0:10:50;  
year='2018'; mon='06';  infilenam='wrfout'; dom='01';  
%
indir='/mnt/HDD123/pwin/Experiments/expri_twin';  outdir='/mnt/e/figures/expri_twin';
titnam=['Cloud area ratio to ',ploterm,''''];  fignam=['cld-',ploterm,'_',exptext,'_'];
%
nexp=size(expri1,1); 
loadfile=load('colormap/colormap_ncl.mat');  col=loadfile.colormap_ncl(15:8:end,:);

%---plot
for ei=1:nexp  
  npi=0; nti=0;
  cldgnum2=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    s_date=num2str(stday+hrday,'%2.2d');   s_hr=num2str(hr,'%2.2d'); 
    for tmi=minu
      nti=nti+1;      s_min=num2str(tmi,'%.2d');
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
%       hyd2D_vec=reshape(hyd2D,300*300,1);
      %---
          
            
        [KE, ThE, LH, Ps, P]=cal_DTEterms(infile1,infile2); 
        dP = P.f2(:,:,2:end)-P.f2(:,:,1:end-1);
        dPall = P.f2(:,:,end)-P.f2(:,:,1);
        dPm = dP./repmat(dPall,1,1,size(dP,3)); 
         DTE3D = KE + ThE + LH ;
         MDTE2D = sum(dPm.*DTE3D(:,:,1:end-1),3) + Ps;
         
         
      
  %---use the largest clouad area in x=50~150, y=50~150, for FLAT
      [nx, ny]=size(hyd2D); 
    rephyd=repmat(hyd2D,3,3);      
    BW = rephyd > cloudhyd;  
    stats = regionprops('table',BW,'BoundingBox','Area','Centroid','MajorAxisLength','MinorAxisLength','PixelList');     
    centers = stats.Centroid;   
    
    if isempty(stats)~=1   
      if ei==1
%         fin=find( centers(:,1)>ny+50 & centers(:,1)<ny+151 & centers(:,2)>nx+50 & centers(:,2)<nx+151);  
         fin=find( centers(:,1)>ny+100 & centers(:,1)<ny+210 & centers(:,2)>nx+150 & centers(:,2)<nx+301); 
      else
        fin=find( centers(:,1)>ny+75 & centers(:,1)<ny+176 & centers(:,2)>nx & centers(:,2)<nx+101);   
      end
    
      if isempty(stats.Area(fin))~=1    
        [maxcldsize, maxcldid]=max(stats.Area(fin));      
        centers_fin=centers(fin,:);      
        cenx=centers_fin(maxcldid,2)-nx;
        ceny=centers_fin(maxcldid,1)-ny;
        
      else
         if ei==1;    cenx=100; ceny=100;    else;    cenx=125; ceny=50;       end
      end
    
      
    else 
      if ei==1;    cenx=150; ceny=150;    else;    cenx=75; ceny=100;       end      
      
    end
    
      %-------------
%      [maxval, maxloc]=max(hyd);  [~, ceny]=max(maxval);  cenx=maxloc(ceny);  % find maximum of hyd
      [yi, xi]=meshgrid(1:ny,1:nx);
      yi(yi-ceny > ny/2)= yi(yi-ceny > ny/2)-ny-1; % for doubly period lateral boundary
      yi(yi-ceny < -ny/2)= yi(yi-ceny < -ny/2)+ny;
      xi(xi-cenx > nx/2)= xi(xi-cenx > nx/2)-nx-1;
      xi(xi-cenx < -nx/2)= xi(xi-cenx < -nx/2)+nx;
      dis2topo=((xi-cenx).^2 + (yi-ceny).^2 ).^0.5;        
      
      cldgnum=length(find(hyd2D+1>cloudhyd+1 & dis2topo<=rang)); 
%       if cldgnum==0; cldgnum=0.5; end
      

        DiffE_m{ei}(nti,1)=double(mean(MDTE2D(dis2topo<=rang)));         % Mean of DTE in the specific range
        cldgptg{ei}(nti,1)=cldgnum/length(dis2topo(dis2topo<=rang))*100;  % Ratio of cloud grids in the specific range

%       if hr==23; s_hrr='00';      s_dater=num2str(stday+hrday+1,'%2.2d'); 
%       else;     s_hrr=num2str(hr+1,'%2.2d'); s_dater=s_date; end
%       infile0=[indir,'/',expri2{ei},'/',infilenam,'_d',dom,'_',year,'-',mon,'-',s_dater,'_',s_hrr,ccc,s_min,ccc,'00'];
%       rain2 = ncread(infile0,'RAINC') + ncread(infile0,'RAINSH') + ncread(infile0,'RAINNC')...
%               -  (ncread(infile2,'RAINC') + ncread(infile2,'RAINSH') + ncread(infile2,'RAINNC') );          
%       rain2_len{ei}(nti,1) = length(find(rain2+1>1));
%        rain2_mean{ei}(nti,1) = mean(mean(rain2));  
%         [maxMDTE, mMDTEloc]=maxk(reshape(MDTE2D,300*300,1),5000);
%         meanMDTE=mean(maxMDTE);
%         meanhyd=mean(hyd2D_vec(mMDTEloc));
%         meanMDTE{ei}(nti,1)=mean(mean(MDTE2D));
%         meanhyd{ei}(nti,1)=mean(mean(hyd2D));
%         cldnum{ei}(nti,1)=length(find(hyd2D>1));
        %
%         plot(meanhyd,meanMDTE,expmark{ei},'MarkerSize',10,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2);    hold on               

        
      
    end % tmi
    disp([s_hr,s_min,' done'])
  end %ti  
  disp([expri2{ei},' done'])
end %ei

% cldgptg{1} ( 1:find(cldgptg{1}>=0.1,1)-4 ) =NaN;
% cldgptg{2} ( 1:find(cldgptg{2}>=0.1,1)-4 ) =NaN;
% cldgptg{3} ( 1:find(cldgptg{3}>=0.1,1)-4 ) =NaN;
% 
% cldgptg{1} ( DiffE_m{1}< 0.003) =NaN;
% cldgptg{2} ( DiffE_m{2}< 0.003) =NaN;
% cldgptg{3} ( DiffE_m{3}< 0.003) =NaN;


%%
hf=figure('Position',[100 65 900 600]);
%---plot
for ei=1:nexp  
  nti=0;
  for ti=hrs 
    for tmi=minu
      nti=nti+1;  
     plot(cldgptg{ei}(nti),DiffE_m{ei}(nti),expmark{ei},'MarkerSize',10,'MarkerFaceColor',col(nti,:),'MarkerEdgeColor',col(nti,:),'linewidth',2);    hold on
        
    end
  end
end
 set(gca,'Yscale','log','fontsize',16,'LineWidth',1.2) 
% set(gca,'xlim',[-100 50000])
set(gca,'Xscale','log')
%%

nti=0;
  for ti=hrs 
    hr=ti;  hrday=fix(hr/24);  hr=hr-24*hrday;
    for tmi=minu
      nti=nti+1;
      s_min=num2str(tmi,'%.2d');
      lgnd{nti}=[num2str(mod(hr+9,24),'%2.2d'),s_min,' LT']; 
    end
  end
%---colorbar for time legend----
nti=length(hrs)*length(minu); tickint=2;
L1=( (1:tickint:nti)*diff(caxis)/nti )  +  min(caxis()) -  diff(caxis)/nti/2;
n=0; for i=1:tickint:nti; n=n+1; llll{n}=lgnd{i}; end
colorbar('YTick',L1,'YTickLabel',llll,'fontsize',13,'LineWidth',1.2);
colormap(col(1:nti,:))
 %%
% set(gca,'Xscale','log','Yscale','log','fontsize',16,'LineWidth',1.2) 
% % set(gca,'Xlim',[5e-2 9e1],'Ylim',[1e-4 3e1])
% %
% % xlabel('Ratio (%)'); 
% % ylabel(['Mean ',ploterm,''' (J kg^-^1)']);
% title([titnam],'fontsize',18)
% % 
% % %---plot legent for experiments---
% % xlimit=get(gca,'Xlim'); ylimit=get(gca,'Ylim');
% % for ei=1:nexp  
% %   plot(10^(log10(xlimit(1))+0.2) , 10^(log10(ylimit(2))-0.4*ei) ,expmark{ei},'MarkerSize',10,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'linewidth',1.5);
% %   text(10^(log10(xlimit(1))+0.3) , 10^(log10(ylimit(2))-0.4*ei) ,expnam{ei},'fontsize',18,'FontName','Consolas','Interpreter','none'); 
% % end
% % 
% % s_sth=num2str(hrs(1),'%2.2d'); s_edh=num2str(mod(hrs(end),24),'%2.2d');
% % outfile=[outdir,'/',fignam,mon,num2str(stday),'_',s_sth,s_edh,'_',num2str(length(hrs)),'hrs','min',num2str(minu(1)),num2str(minu(2)),'_r',num2str(rang)];
%%
Lmap=[0.1 0.4 0.7 1.1 5 10 15 20 30 40];

cmap=loadfile.colormap_ncl(17:21:end-10,:);

figure('Position',[100 65 900 600])

for ei=1:nexp
 plot_dot(1:nti,DiffE_m{ei},cldgptg{ei},cmap,Lmap,expmark{ei},10)
end
% plot(DiffE_m{1},'linewidth',2.5)

% hold on; plot(DiffE_m{2},'linewidth',2.5)
set(gca,'yscale','log')


