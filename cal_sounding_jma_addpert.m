clear 

%--- setting ----
year='2019';  mon='08';  date='19';  hr='00';  minu='00';
Wind=importdata(['/mnt/e/data/sounding/shionomisaki_',year,mon,date,'_',hr,minu,'_wind.txt']);
Temp=importdata(['/mnt/e/data/sounding/shionomisaki_',year,mon,date,'_',hr,minu,'_temp.txt']);
%-------------
outfilenam=['/mnt/HDD003/pwin/Data/sounding/sounding_shionomisaki_',year,mon,date,hr,minu];
%------------
R=287.43;
cp=1005;
eps=0.622;

T_K=Temp(:,3)+273;
theta=T_K.*(1000./Temp(:,1)).^(R/cp);

%
es=6.1094*exp(17.625.*Temp(:,3)./(Temp(:,3)+243.04));
ew=es.*Temp(:,4)/100;
qv=eps*ew./(Temp(:,1)-ew)*1000;

%%
% add perturbation
%{
pertb=0.1;
ws_pert=Wind(:,3)+ pertb * randn(1,length(Wind(:,3)))';
wd_pert=Wind(:,4)+ pertb * randn(1,length(Wind(:,4)))';
% qv_pert=qv+ pertb * randn(1,length(qv))';
qv_pert=qv;
% theta_pert=theta+ pertb * randn(1,length(theta))';
theta_pert=theta;
%}
%%
% set wind to zero
%{
ws_pert=zeros(length(Wind(:,3)),1);
wd_pert=Wind(:,4);
qv_pert=qv;
theta_pert=theta;

outfilenam=[outfilenam,'_noWind']
%}
%%
% idealized wind profile

z=Wind(:,2)./1000;
z0=3; %km
Us=25;  outfilenam=[outfilenam,'_U25'];

ws_pert=Us*tanh(z./z0);
wd_pert=zeros(length(Wind(:,3)),1)+270;  % westly wind
qv_pert=qv;
theta_pert=theta;


%%

 for i=88:102
     qv_pert(i)=qv_pert(i-1)+mean(qv_pert(i-2:i-1)-qv_pert(i-3:i-2));
 end
qv_pert(qv_pert<0)=0;

u=ws_pert.*cos((270-wd_pert)*pi/180);
v=ws_pert.*sin((270-wd_pert)*pi/180);

u_int = interpn(Wind(:,2),u,Temp(:,2));
v_int = interpn(Wind(:,2),v,Temp(:,2));

out(:,1)=Temp(:,2);
out(:,2)=theta_pert;
out(:,3)=qv_pert;
out(:,4)=u_int;
out(:,5)=v_int;
% 
fin=find(Temp(:,1)==1000);  %for writing first line of input_sounding format
%%
%  fid = fopen(['E:/data/sounding/sounding_shionomisaki_',year,mon,date,hr,minu,'_weakenwind'],'wt');
 fid = fopen(outfilenam,'wt');
 for i = 1:size(out,1)
     if i==1
          fprintf(fid,'%13.4f%13.4f%12.6f\n',Temp(fin,1),out(fin,2),out(fin,3));
     end
     fprintf(fid,'%13.4f%13.4f%12.6f%13.4f%13.4f\n',out(i,:));
     %fprintf(fid,'%12.4f   %12.4f   %12.5f%9.1f  %9.1f\n',out(i,:));   %convrad
 end
 fclose(fid);
