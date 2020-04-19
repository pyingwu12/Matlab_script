clear 

%--- setting ----
year='2019';  mon='08';  date='19';  hr='00';  minu='00';

Wind=importdata(['E:/data/sounding/shionomisaki_',year,mon,date,'_',hr,minu,'_wind_modified.txt']);
Temp=importdata(['E:/data/sounding/shionomisaki_',year,mon,date,'_',hr,minu,'_temp_modified.txt']);
%-------------
R=287.43;
cp=1005;
eps=0.622;

T_K=Temp(:,3)+273;
theta=T_K.*(1000./Temp(:,1)).^(R/cp);

es=6.1094*exp(17.625.*Temp(:,3)./(Temp(:,3)+243.04));
ew=es.*Temp(:,4)/100;
qv=eps*ew./(Temp(:,1)-ew)*1000;
 for i=88:102
     qv(i)=qv(i-1)+mean(qv(i-2:i-1)-qv(i-3:i-2));
 end
qv(qv<0)=0;
 
u=Wind(:,3).*cos((270-Wind(:,4))*pi/180);
v=Wind(:,3).*sin((270-Wind(:,4))*pi/180);

u_int = interpn(Wind(:,2),u,Temp(:,2));
v_int = interpn(Wind(:,2),v,Temp(:,2));

out(:,1)=Temp(:,2);
out(:,2)=theta;
out(:,3)=qv;
out(:,4)=u_int;
out(:,5)=v_int;
% 
fin=find(Temp(:,1)==1000);  %for writing first line of input_sounding format
%
 fid = fopen(['E:/data/sounding/sounding_shionomisaki_',year,mon,date,hr,minu,'_test'],'wt');
 for i = 1:size(out,1)
     if i==1
          fprintf(fid,'%13.4f%13.4f%12.6f\n',Temp(fin,1),out(fin,2),out(fin,3));
     end
     fprintf(fid,'%13.4f%13.4f%12.6f%13.4f%13.4f\n',out(i,:));
     %fprintf(fid,'%12.4f   %12.4f   %12.5f%9.1f  %9.1f\n',out(i,:));   %convrad
 end
 fclose(fid);
