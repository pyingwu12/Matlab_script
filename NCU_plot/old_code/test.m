

clear
expri='e01';  memsize=256;

hm=['00:00'];  vonam='Vr';  vmnam='QVAPOR';

infilenam='fcst';    dirnam='cycle';  type=infilenam;

%---experimental setting---
dom='02'; year='2008'; mon='06'; date='16';    % time setting
indir1=['/work/pwin/data/largens_wrf2obs_',expri];  %!!! use onlyobs when use obs to choicce points
indir2=['/SAS009/pwin/expri_largens/',expri];

addpath('/work/pwin/m_map1.4/')
addpath('/work/pwin/data/colorbar/')
addpath('/SAS011/pwin/201work/plot_cal')

cmap=[ 220 220 220; 150 150 150;  65 65 65;  217 154 159;  199  85  66;  117  33  10 ]./255;
L=[0.1 0.3 0.5 0.7 0.9];

%---set
ng=36;  ng2=ng*2+1;
voen=zeros(memsize,1);
vmen=zeros(ng2,memsize);
g=9.81;
%
num=size(hm,1);
plon=[118 122.5]; plat=[20.1 25];

%-----
for ti=1:num

  s_hr=hm(ti,1:2);  minu=hm(ti,4:5);

  infile=['/SAS011/pwin/201work/data/wrf2obs_uv/largens_wrf2obs_',expri,'/fcstmean','_d',dom,'_',year,'-',mon,'-',date,'_',s_hr,':',minu,':00'];

  A=importdata(infile); rad=A(:,1); ela=A(:,2); aza=A(:,3);  vr=A(:,8);  lon=A(:,5); lat=A(:,6); alt=A(:,7);
  sou=A(:,10);  sov=A(:,11);

  spe=sqrt(sou.^2+sov.^2);
  per=abs(vr./spe);

  %fin_vr=find( rad==3 & ela==0.5  & aza>123 & aza<318 & A(:,4)>50 & A(:,4)<105 );  
  fin_vr=find( rad==3  & ela==0.5 );  

  Var=per(fin_vr); lon=lon(fin_vr); lat=lat(fin_vr);
  clen=length(cmap);

%-----
figure('position',[100 100 600 500])
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',121,'parallels',[33.65 13.65],'rectbox','on')

  
  for i=1:length(Var)
    for k=1:clen-2;
      if (Var(i) > L(k) && Var(i)<=L(k+1))
        c=cmap(k+1,:);
        hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',5); hold on
        set(hp,'linestyle','none');
      end
    end
    if Var(i)>L(clen-1)
       c=cmap(clen,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',5); hold on
       set(hp,'linestyle','none');
    end
    if Var(i)<L(1)
       c=cmap(1,:);
       hp=m_plot(lon(i),lat(i),'o','MarkerEdgeColor','none','MarkerFaceColor',c,'MarkerSize',5); hold on
       set(hp,'linestyle','none');
    end
  end
end


  m_grid('fontsize',12,'LineStyle','-.','LineWidth',1,'xtick',115:1:130,'ytick',17:1:45);
  m_gshhs_h('color','k','LineWidth',0.8);
  %m_coast('color','k');
  cm=colormap(cmap);    caxis([L(1) L(length(L))]);
  hc=Recolor_contourf(hp,cm,L,'vert');   set(hc,'fontsize',13,'LineWidth',1);


%   s_hr=num2str(hr,'%.2d');
%   tit=[varinam,'  ',s_hr,'z'];
%   title(tit,'fontsize',15)
%   outfile=[outdir,'/',filenam,s_hr,minu,'_',vonam,'-',lower(s_vm),'_sub',num2str(sub)];
%    set(gcf,'PaperPositionMode','auto');  print('-dpdf',[outfile,'.pdf'])
%    system(['convert -trim -density 250 ',outfile,'.pdf ',outfile,'.png']);
%    system(['rm ',[outfile,'.pdf']]);


