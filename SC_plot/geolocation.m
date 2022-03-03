truthfile1='/SAS001/cctsai/cycle/truth_obs/wrfout_d03_2009-08-08_18:00:00';
xlon=(getnc(truthfile1,'XLONG',[1 -1 -1],[1 -1 -1]))';
ylat=(getnc(truthfile1,'XLAT',[1 -1 -1],[1 -1 -1]))';
lon=119.0125;
lat= 23.04130 
lons=reshape(xlon,198*198,1);
lats=reshape(ylat,198*198,1);
i=find(abs(lons-lon)<0.01 & abs(lats-lat)<0.01);
for j=1:size(i)
jy=mod(i(j),198);
if(jy==0);jy=198;end;
jx=(i(j)-jy)/198+1;
[jx jy]
[lon lat xlon(jy,jx) ylat(jy,jx)]
end
