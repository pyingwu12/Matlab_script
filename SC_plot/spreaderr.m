
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

expdir{1}='/SAS001/ailin/SHAND25/PT37_2/TRUTH/ensbdy/';
expdir{2}='/SAS001/scyang/WRFEXPS/exp09/osse/e01/da_out/'; %k
expdir{3}='/SAS001/scyang/WRFEXPS/exp09/osse/e03/da_out/';

hh=12; dd=15;
tag0=['2006-09-',num2str(dd,'%2.2d'),'_',num2str(hh,'%2.2d'),':00:00'];
run=3;
for i=1:run
        switch(i)
        case(1) 
           file=strcat([expdir{1},'wrf_3dvar_input_d01_'],[tag0,'_28']);
        otherwise
           file=[expdir{i},'wrfanal_d01_',tag0];
        end
        n=1;
        [u,v,th,qv,temp,slp,pressure]=getnc_vars(file,n,xlon,ylat,eta);
        eval(['u',num2str(i),'=u;']);
end
uerr1=u2-u1;
uerr2=u3-u1;
%maindir{1}='/SAS001/ailin/SHAND25/PT37_2/';
xens=zeros(26,150,150,36);
for i=1:36
   file=['../input/wrfinput_d01_148180_43200_',num2str(i)];
   infile=strcat(expdir{2},file);
   n=1;
   [utmp,vtmp,w,th,qv,temp,slp,pressure]=getnc_vars(infile,n,xlon,ylat,eta);
   xens(:,:,:,i)=utmp;
end
xbar=mean(xens,4);
for i=1:36; xens(:,:,:,i)=xens(:,:,:,i)-xbar; end
for k=1:26
for j=1:150
for i=1:150
    y1(i,j,k)=std(xens(k,j,i,:));
end
end
end

xens=zeros(26,150,150,36);
for i=1:36
   file=['../input/wrfinput_d01_148180_43200_',num2str(i)];
   infile=strcat(expdir{3},file);
   n=1;
   [utmp,vtmp,w,th,qv,temp,slp,pressure]=getnc_vars(infile,n,xlon,ylat,eta);
   xens(:,:,:,i)=utmp;
end
xbar=mean(xens,4);
for i=1:36
    xens(:,:,:,i)=xens(:,:,:,i)-xbar;
end
for k=1:26
for j=1:150
for i=1:150
    y2(i,j,k)=std(xens(k,j,i,:));
end
end
end

