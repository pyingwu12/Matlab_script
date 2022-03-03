
%   plot the fcst and analysis errors
%
clear all
figure(2);clf
%close all
addpath('/work/scyang/matlab/lib')
addpath('/work/scyang/matlab/map/m_map/')

dom='d01';

switch(dom)
case('d01')
   expmain='/SAS001/ailin/SHAND25/PT37_2/';
   file0=['wrfinput_',dom,'_148179_0_19'];
   lat1=12.5; lat2=32.5;
   lon1=112.5;lon2=137.5;
case('d02')
   expmain='/mnt/ddal01/scyang/WRFEXPS/exp07/test_init/';
   %file0=['wrfinput_',dom];
   file0='wrf_real_input_em.d02.2006-09-12_12:00:00';
   lat1=12.5; lat2=32.5;
   lon1=112.5;lon2=137.5;
end
%[lon,lat]=meshgrid([lon1:dlon:lon2],[lat1:dlat:lat2]);
xlon  =getnc([expmain,file0],'XLONG');
ylat  =getnc([expmain,file0],'XLAT');
eta  = getnc([expmain,file0],'ZNU');
var={'T';'U';'V';'QVAPOR';'PSFC'};

maindir{1}='/SAS001/ailin/SHAND25/PT37_2/';
xens=zeros(26,150,150,36);
for i=1:36
   file=['wrfinput_d01_148179_0_',num2str(i)];
   infile=strcat(maindir{1},file);
   n=1;
   [utmp,vtmp,w,th,qv,temp,slp,pressure]=getnc_vars(infile,n,xlon,ylat,eta);
   xens(:,:,:,i)=utmp;
end
xbar=mean(xens,4);
for i=1:36
    xens(:,:,:,i)=xens(:,:,:,i)-xbar;
end
for k=1:26
for i=1:150
for j=1:150
    y(i,j,k)=std(xens(k,i,j,:));
end
end
end
ustd=mean(mean(mean(y(60:end,0:100,:),1),2));
