

close all
clear

addpath('/data8/wu_py/MATLAB/m_map/')

saveid=1;

year='2019'; mon='10'; days=11:13; hrs=0:23; minu='00';
indir='/data8/wu_py/Data/obs/';

outdir='/home/wu_py/labwind/Result_fig';
if ~isfolder(outdir); outdir='/data8/wu_py/Result_fig'; end

fignam0='amedas_wind_';

plon=[138 141]; plat=[34 37.3];  fignam=[fignam0,'ktp_']; lo_int=130:2:146; la_int=25:2:45; msize=13;  %Kantou portrait(verticle)
% plon=[139.2 140.9]; plat=[34.85 36.3 ];  fignam='amedas_wind_tokyobay'; lo_int=134:2:145; la_int=31:2:40;
% plon=[135.5 142.5]; plat=[33.5 37];  fignam='amedas_wind_zkt';  lo_int=135:5:145; la_int=30:5:40; msize=12; % zoom in Kantou area
% plon=[135.5 142.3]; plat=[33.5 37.3];  fignam='amedas_wind_zkt2';  lo_int=134:2:145; la_int=31:2:40; msize=12; % zoom in Kantou area
%%
% ntime=length(days)*length(hrs);
%---
nti=0;
for dy=days
  for hr=hrs
  nti=nti+1;  
  
  infile=[indir,'amds_',year,mon,num2str(dy,'%.2d'),num2str(hr,'%.2d'),minu,'.txt'];
  A=importdata(infile);   
  if nti==1;  lon=A(:,7); lat=A(:,8); sta_num_ini=A(:,1); wind_dir(:,nti)=A(:,10); wind_speed(:,nti)=A(:,9);
  else
    for ista=1:size(A,1)
      fi=find(sta_num_ini==A(ista,1), 1);      
      if isempty ( fi )==1
      sta_num_ini(end+1)=A(ista,1);  lon(end+1)=A(ista,7); lat(end+1)=A(ista,8);
      wind_dir(end+1,1:nti-1)=NaN;   wind_speed(end+1,1:nti-1)=NaN;
      wind_dir(end,nti)=A(ista,10);  wind_speed(end,nti)=A(ista,9);        
      else        
      wind_dir(fi,nti)=A(ista,10);
      wind_speed(fi,nti)=A(ista,9);
      end
    end % for ista
  end %if nti==1  
  
  end % hrs
end %days
%%

% load('colormap/colormap_wind.mat') 
% % cmap=colormap_wind([3 5 9 11 12 13 16],:); 
% cmap =[    
%     0.0784313725490196,0.0431372549019608,0.725490196078431
%     0.1961    0.3137    0.9020
%     0.2745    0.5882    0.9412
%     0.941176470588235,0.901960784313726,0.196078431372549
%     0.98 0.5 0.16
%     1,0.15,0.0431
%     0.3    0.3    0.3];
% colL=5:5:30;

load('colormap/colormap_wind2.mat') 
cmap=colormap_wind2([2 3 5 9 11 13 14],:); cmap(end,:)=[0.72 0.03 0.7];
colL=[5 10 15 20 25 30];
%---
%%
B=importdata('/data8/wu_py/Data/Hagibis_hazard.txt',',');
h_lat=B.data(:,2);
h_lon=B.data(:,3);
%%
hf=figure('Position',[100 100 800 630]);
% 
m_proj('Lambert','lon',plon,'lat',plat,'clongitude',140,'parallels',[30 60],'rectbox','on')
% 
m_color_point(lon, lat, max(wind_speed,[],2), cmap,colL,'o',msize,'none'); hold on

m_grid('fontsize',13,'LineStyle','-.','LineWidth',0.8,'xtick',lo_int,'ytick',la_int);
m_usercoast('gumby','linewidth',1.2,'color',[0.2 0.2 0.2])
% m_coast('color','k');
% m_gshhs_h('color','k','LineWidth',0.8);  m_gshhs_h('save','gumby');

title('Amedas wind speed (temporal max.)','fontsize',18)
outfile=[outdir,'/',fignam,'max'];

L1=((1:length(colL))*(diff(caxis)/(length(colL)+1)))+min(caxis());
hc=colorbar('YTick',L1,'YTickLabel',colL,'fontsize',14,'LineWidth',1.3);
colormap(cmap); title(hc,'m/s','fontsize',14) 
set(hc,'position',[0.8 0.13 0.02 0.74]);

% %--- reported harzard
% col=[0.01,0.25,0.1];
% fin=find(B.data(:,1)<50 );
% m_plot(h_lon(fin),h_lat(fin),'+','Markersize',10,'linewidth',2.5,'color',col)
% fin=find(B.data(:,1)<100 & B.data(:,1) >50);
% m_plot(h_lon(fin),h_lat(fin),'^','Markersize',10,'linewidth',2.5,'color',col)
% fin=find( B.data(:,1) >100);
% m_plot(h_lon(fin),h_lat(fin),'s','Markersize',10,'linewidth',2.5,'color',col)
% % m_plot(h_lon(B.data(:,1)==0),h_lat(B.data(:,1)==0),'x','Markersize',10,'linewidth',2.5,'color',[0.1,0.6,0.05])
% % m_plot(h_lon(B.data(:,1)~=0),h_lat(B.data(:,1)~=0),'^','Markersize',10,'linewidth',2.5,'color',[0.1,0.6,0.05])
% % m_plot(h_lon(B.data(:,1)==0),h_lat(B.data(:,1)==0),'x','Markersize',12,'linewidth',2.5,'color',[0.1,0.6,0.05])
% title('Amedas wind speed and reported damage','fontsize',18)
% outfile=[outdir,'/',fignam,'harzard'];


if saveid==1
  print(hf,'-dpng',[outfile,'.png'])    
  system(['convert -trim ',outfile,'.png ',outfile,'.png']);
end
