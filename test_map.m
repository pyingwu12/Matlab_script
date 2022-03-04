load coastlines
axesm miller
axis off
framem on
gridm on
[topo60c,topo60cR] = geocrop(topo60c,topo60cR,[-90 90],[-180,180]);
[lat,lon] = geographicGrid(topo60cR);
% plotm(lat,lon,topo60c)
plotm(coastlat,coastlon,'g')
demcmap(topo60c)
tightmap

load coastlines
ax = axesm('miller','Frame','on');
plotm(coastlat,coastlon,'g')

lat = [0 1 2 NaN 4 5 6];
lon = [0 1 2 NaN 3 4 5];
axesm('UTM','Zone','31N','Frame','on')
plotm(lat,lon)


[N,R] = egm96geoid;
load coastlines

lonlim = [131 146];
latlim = [28 43];
worldmap(latlim,lonlim)
geoshow(coastlat,coastlon,'Color','k')

clf


contourf(lon,lat,spd,20,'linestyle','none')
hold on 
C = load('coast');
plot(C.long,C.lat,'k')


contourf(lon, lat, spd,'linestyle','none');hold on
shading flat 
load coastlines
axesm('eqaconic','MapLatLimit',[20 50],'MapLonLimit',[110 150])
plotm(coastlat,coastlon)