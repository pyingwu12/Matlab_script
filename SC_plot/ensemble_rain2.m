addpath('/work/ailin/matlab/map/m_map/')
addpath('/work/scyang/matlab/mexcdf/mexnc')
addpath('/work/scyang/matlab/matlab_netCDF_OPeNDAP/');
addpath('/work/ailin/matlab/suplabel/')
addpath('/work/ailin/matlab/Discrete_colors')
addpath('/work/scyang/WRFEXPS/plot/')
constants;
%fdir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e41/fcst/wrfout_d03_2008-06-15_12:00:00'
iread=0;
if(iread==0)
count_1=zeros(150,150);
count_2=zeros(150,150);
count_3=zeros(150,150);
count_4=zeros(150,150);
thres_1=50;
thres_2=100;
thres_3=130;
thres_4=160;
for k=1:36
    main_dir=['/SAS001/zerocustom/20120608/fcstFrom2008061512/cycle_',num2str(k,'%2.2d')];
    fdir=[main_dir,'/wrfout_d03_2008-06-15_12:00:00'];
    [xlon,ylat,R]=get_rainfall(fdir); 
    index_1=find(R>thres_1);
    index_2=find(R>thres_2);
    index_3=find(R>thres_3);
    index_4=find(R>thres_4);
    count_1(index_1)=count_1(index_1)+1;
    count_2(index_2)=count_2(index_2)+1;
    count_3(index_3)=count_3(index_3)+1;
    count_4(index_4)=count_4(index_4)+1;
    clear index_1
    clear index_2
    clear index_3
    clear index_4
end
Pr1=100*count_1/36;
Pr2=100*count_2/36;
Pr3=100*count_3/36;
Pr4=100*count_4/36;
end
%clevs=[0 20 40 60 80 90 100];
clevs=[20 40 60 80 90];
cols=jet(20);
colors(1,:)=[1 1 1];
colors(2,:)=[43 143 198]/255;%cols(5,:);
colors(3,:)=[0 234 58]/255;%cols(10,:);
colors(4,:)=[255 199 30]/255;%cols(15,:);
%colors(4,:)=[231 151 3]/255;%cols(15,:);
colors(5,:)=[181 0 0]/255;%cols(19,:);
%colors(6,:)=[240 0 240]/255;
colors(6,:)=[ 255   172   255]/255;
colormap(colors);
%[clevs des_color]=CWBRainColor;
%colors(2:10,:)=des_color(3:15,:);
figure(1);clf
for i=1:4
eval(['R=Pr',num2str(i),';']);
subplot(2,2,i)
m_proj('Mercator','long',[118 122],'lat',[21.5 25.5]); hold on
%cmp=colormap(colors);
%[c,h]=m_contourf(xlon,ylat,R,[clevs]);hold on
[ss hh]=m_contourf(xlon,ylat,R,clevs,'lineStyle','none');
colormap(colors);
hbar=Recolor_contourf(hh,colors,clevs);
if ( i==4 )
  hbar=Recolor_contourf(hh,colors,clevs,'h');
end
%[hbar]=Recolor_contourf(h,cmp,clevs);
%caxis([0 100])
%[hbar]=Recolor_contourf(h,cmp,clevs);
m_gshhs_i('color',[0.2 .2 0.2],'linewidth',2.0)
m_grid('linest','none','box','on','tickdir','in','backcolor','none','fontsize',12)
eval(['thres=thres_',num2str(i)])
titname=['QPF Prob. (',num2str(thres),' mm/day)']
title(titname,'fontsize',14,'fontweight','bold')
%set(h,'linestyle','none')
set(gca,'fontsize',14)
if (i==1)
  set(gca,'position',[0.05 0.55 0.4 0.4],'fontsize',14)
elseif (i==2)
  set(gca,'position',[0.55 0.55 0.4 0.4],'fontsize',14)
elseif (i==3)
  set(gca,'position',[0.05 0.1 0.4 0.4],'fontsize',14)
elseif (i==4)
  set(gca,'position',[0.55 0.1 0.4 0.4],'fontsize',14)
end
drawnow
end
pos=get(gca,'position');
%[hbar]=Recolor_contourf(h,cmp,clevs,'horizontal');
%hbar=colorbar('SOUTHOutside')
set(hbar,'position',[0.135 0.05 0.76 0.02]);
%set(hbar,'Xtick',[clevs])
set(gca,'position',pos)
return
subplot(2,2,1)
titname='(d) NoBANGLE'
Func_rainfall(fdir,1,titname);
%Func_rainfall_20120308(fdir,1,titname);
set(gca,'position',[0.05 0.55 0.4 0.4],'fontsize',14)
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 8 10])
return

fdir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e49a/fcst/init_ensavg/wrfout_d03_2008-06-15_12:00:00'
%fdir='/SAS002/ailin/2008IOP8/FCST_test/geo_2m/MP7/CU3/wrfout_d03_2008-06-15_12:00:00'
subplot(2,2,2)
%titname='(b) Refractivity'
titname='(e) BANGLE-A'
Func_rainfall(fdir,1,titname);
%Func_rainfall_20120308(fdir,1,titname);
set(gca,'position',[0.55 0.55 0.4 0.4],'fontsize',14)

fdir='/SAS002/ailin/2008IOP8/FCST_test/geo_2m/MP7/CU3/wrfout_d03_2008-06-15_12:00:00'
%fdir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e21/fcst/d02/wrfout_d02_2008-06-15_12:00:00'
%fdir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e48b_nobangle1500/fcst/wrfout_d03_2008-06-15_12:00:00'
subplot(2,2,3)
titname='(f) FNL'
Func_rainfall(fdir,1,titname);
%Func_rainfall_20120308(fdir,1,titname);
set(gca,'position',[0.05 0.1 0.4 0.4],'fontsize',14)

load('/work/zerocustom/20120308/autoStnPrep_day3_interp.mat')
prepInterp(prepInterp==0)=-1e-6;
subplot(2,2,4)
lon1=119.4;
lon2=120.;
lon3=120.6;
lon4=121.2;
lat1=22.;
lat2=23.5;
titname='(d) Observation'
[clevs des_color]=CWBRainColor;
[matcolor]=RGB(des_color(:,1),des_color(:,2),des_color(:,3));
m_proj('Mercator','long',[118 122],'lat',[21.5 25.5]); hold on
cmp=colormap(matcolor);
[c,h]=m_contourf(lonInterp,latInterp,prepInterp,[0 clevs]);hold on
[hbar]=Recolor_contourf(h,cmp,clevs,'horizontal');
m_plot([lon1 lon4],[lat1 lat1],'k')
m_plot([lon1 lon4],[lat2 lat2],'k')
m_plot([lon1 lon1],[lat1 lat2],'k')
m_plot([lon2 lon2],[lat1 lat2],'k')
m_plot([lon3 lon3],[lat1 lat2],'k')
m_plot([lon4 lon4],[lat1 lat2],'k')

set(hbar,'position',[0.1 0.04,0.8,0.02])
m_gshhs_i('color',[0.2 .2 0.2],'linewidth',2.0)
m_grid('linest','none','box','on','tickdir','in','backcolor','none','fontsize',12);    
title(titname,'fontsize',14,'fontweight','bold')
set(h,'linestyle','none')
set(gca,'position',[0.55 0.1 0.4 0.4],'fontsize',14)
drawnow
set(gcf,'paperorientation','portrait','paperposition',[0.25 0.5 8 10])

return

%=residual=======================================

%fdir='/SAS001/scyang/WRFEXPSV3/2008IOP8/e05/fcst/wrfout_d03_2008-06-15_12:00:00'
subplot(2,2,4)
titname='(d) BANGLE-B'
Func_rainfall(fdir,0,titname);
set(gca,'position',[0.55 0.1 0.4 0.4],'fontsize',14)

