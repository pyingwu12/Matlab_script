clear all
addpath('/work/ailin/matlab/windbarb/');
addpath('/work/ailin/matlab/map/m_map/')
%%% read the obs
obsfile='/SAS002/SAS001_Backup/ailin/GTS/obs080612-18/IOP8_obs/res27//SYNOP/obs_2008-06-16_06_00_00';
fid=fopen(obsfile,'r');
for i=1:551
head=fscanf(fid,'%f %f %f %f %f',5);
obs=fscanf(fid,'%f %f %f %f %f %f',6);
xo(i)=head(1);
yo(i)=head(2);
uo(i)=obs(2);
vo(i)=obs(3);
end

xlon=111.99467:0.04054054:111.99467+0.04054054*(394-1);
ylat=16.65020:0.04054054:16.65020+0.04054054*(332-1);

file='wrfanal_d02_2008-06-16_06:00:00';
maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/';
xlon  = (getnc([maindir,file],'XLONG'))';
ylat  = (getnc([maindir,file],'XLAT'))';
hgt  = (getnc([maindir,file],'HGT'))';

%nx=394;ny=332;
x=115:0.04:115+0.04*250;
y=19:0.04:19+0.04*225;
[xx,yy] = meshgrid(x,y);

nx=159;ny=150;
var=zeros(nx,ny);
fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/D2/e20/da_out/anal_d02_2008-06-16_06:00:00.dat','r','b');
%dummy=fread(fid,1,'int');
var=fread(fid,[nx,ny],'float');
for i=1:7*25+2+3*25+4
    var=fread(fid,[nx,ny],'float');
    var(find(var>=1.e10))=nan;
end
U10=fread(fid,[nx,ny],'float');
V10=fread(fid,[nx,ny],'float');
u10s = griddata(xlon,ylat,U10,xx,yy);
v10s = griddata(xlon,ylat,V10,xx,yy);
clf
scale=0.2;
fullbar=25;
%line([117 123],[21 25],'color','w');
%xlim([117.5 122.5]);
%ylim([21.5 25.5]);
col=summer(10);
for i=1:10
    cols(i,:)=col(10-i+1,:);
end
cols(1,:)=1.0;
figure(1);clf
[c,h]=contourf(xlon,ylat,hgt,[0:250:2500]);hold on
caxis([0 2500])
set(h,'linestyle','none');
colormap(cols);
hbar=colorbar;
set(hbar,'ytick',[0:250:2500])
xm = get(gca,'XLim');
ym = get(gca,'YLim');
ylim(ym)
xlim(xm)
axis([117.5 122.5 21.5 25.5])

%windbarbM(xx(1:6:end,1:6:end),yy(1:6:end,1:6:end),u10s(1:6:end,1:6:end),v10s(1:6:end,1:6:end),scale,fullbar,'r',2.); hold on
windbarbM(xx(1:3:end,1:3:end),yy(1:3:end,1:3:end),u10s(1:3:end,1:3:end),v10s(1:3:end,1:3:end),scale,fullbar,'r',2.); hold on

clear xlon ylat;

maindir='/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/';
file='wrfanal_d01_2008-06-16_06:00:00';
xlon  = (getnc([maindir,file],'XLONG'))';
ylat  = (getnc([maindir,file],'XLAT'))';
nx=180;ny=150;
var=zeros(nx,ny);
fid=fopen('/SAS003/scyang/WRFEXPSV3/2008IOP8/new/e18_1deg_upper/da_out/anald01_2008-06-16_06:00:00.dat','r','b');
var=fread(fid,[nx,ny],'float');
for i=1:7*25+2+3*25+4
    var=fread(fid,[nx,ny],'float');
    var(find(var>=1.e10))=nan;
end
U10=fread(fid,[nx,ny],'float');
V10=fread(fid,[nx,ny],'float');
u10s = griddata(xlon,ylat,U10,xx,yy);
v10s = griddata(xlon,ylat,V10,xx,yy);
windbarbM(xx(1:3:end,1:3:end),yy(1:3:end,1:3:end),u10s(1:3:end,1:3:end),v10s(1:3:end,1:3:end),scale,fullbar,'b',2.); hold on

for i=1:551
    if(xo(i)>=117.5 & xo(i)<=122.5 & yo(i)>=21.5 & yo(i)<=25.5)
    windbarbM(xo(i),yo(i),uo(i),vo(i),scale,fullbar,'k',2.); hold on
    end
end
return
%dummy=fread(fid,1,'int');
fclose(fid)
return
for i=1:7*25+2+3*25+4
    var=fread(fid,[nx,ny],'float');
end
fclose(fid)
