% clear

infile='/mnt/HDD008/pwin/Experiments/expri_twin/TWIN003B/wrfout_d01_2018-06-22_21:00:00';

g=9.81;
Rd=287.04; % Specific gas constant
cvd=719;   % specific heat capacity at constant volume
cpd=Rd+cvd;  % Isobaric specific heat



lapse_d=g/cpd; % dry adiabatic lapse rate (K/m)

es0=6.112; %(hpa)
T0=273.16;
Lv=(2.4418+2.43)/2 * 10^6 ;
% Lv=2.5 * 10^6 ;
cpv = 1850;  % Isobaric specific heat of vapor
cpw = 4218;  % Specific heat capacity of liquid water
Rv = 461.51;

% epsilon=0.622; % epsilon=Rd/Rv=Mv/Md
epsilon=Rd/Rv; % epsilon=Rd/Rv=Mv/Md

%-----------------
hgt = ncread(infile,'HGT');  
t = ncread(infile,'T');        t=double(t)+300;  % potential temp.
qv = ncread(infile,'QVAPOR');  
ph = ncread(infile,'PH');      phb = ncread(infile,'PHB');
p = ncread(infile,'P');        pb = ncread(infile,'PB');   

[nx ,ny, ~]=size(t);


P  = double(p+pb); %pressure (pa)
PH0= double(phb+ph); PH=(PH0(:,:,1:end-1)+PH0(:,:,2:end)).*0.5;   
zg = PH/g;  %height (m)    
T  = t.*(1e5./P).^(-Rd/cpd); %temperature (K)


lev=1;
h_int=0:1000;
nh=length(h_int);

T_start=T(:,:,lev);
qv_start=qv(:,:,lev);
P_start=P(:,:,lev);
ev_start=qv_start./(epsilon+qv_start) .* P_start/100; 

lapse_d_all=lapse_d*reshape(h_int,1,1,[]);

T_lapse_d= repmat(T_start,1,1,nh) - repmat( lapse_d_all,nx,ny );
%%
 esw = 6.11*exp(53.49-6808./T_lapse_d-5.09*log(T_lapse_d));
% esw = 6.11*exp(19.83-5417./T_lapse_d);
% esw = es0 * exp( (Lv+(cpw-cpv)*T0)/Rv * (1/T0-1./T_lapse_d) - (cpw-cpv)/Rv*log(T_lapse_d/T0)  );
%%

for i=1:nx    
  for j=1:ny      
    fin=find(esw(i,j,:)<=ev_start(i,j), 1 );
    Zlcl(i,j) = zg(i,j,1) + h_int(fin) ;    
    Tlcl(i,j)=T_lapse_d(i,j,fin);
  end
end
%%

%%
% Tlcl=2840/(3.5*log(T)-log(ev)-4.805)+55;   

%     hP=P/100; %pressure in hap
%     ev2=qv./epsilon.*hP;   %partial pressure of water vapor
%     Td=-5417./(log(ev2./6.11)-19.83);    %caculate Tdew by C-C equation and partial pressure of water vapor 
%     Zlcl=( zg(:,:,1)*1e-3+(T(:,:,1)-Td(:,:,1))/8 )*1e3;

%-----------------------------------------


% for i=1:nx    
%   for j=1:ny      
%     X=squeeze(zg(i,j,:));
%     Y=squeeze(T(i,j,:));   
%     T_inth(i,j,:)=interp1(X,Y,1:2500,'linear');
%   end
% end



cpm=(1-qv_start)*cpd  +qv_start*cpv;
Rm=(1-qv_start)*Rd + qv_start*Rv;

Plcl=P_start.*(Tlcl./T_start).^(cpm./Rm);
%%
int_h=1;

for i=1:nx    
  for j=100     
 
      
    for h=1:int_h:10000
       
      if h==1
       T2=Tlcl(i,j);   P2=Plcl(i,j);    qv2=qv_start(i,j);
      end   
      lapse_w= g .* (Rd*T2.^2 + Lv*qv2.*T2 ) ./ (cpd*Rd*T2.^2 + Lv^2*qv2*epsilon);
  
      P2=P2+(P2./(Rd.*T2))*g*int_h;
      T2=T2+lapse_w; 
      esw2 = es0 * exp( (Lv+(cpw-cpv)*T0)/Rv * (1/T0-1./T2) - (cpw-cpv)/Rv*log(T2/T0)  );
      qv2=epsilon*esw2./(P2/100-esw2);  
  
      Z2=Zlcl(i,j)+h;
 
       
      X=squeeze(zg(i,j,:));    Y=squeeze(T(i,j,:));   
      T_Z2=interp1(X,Y,Z2,'linear');
     
      if T2>T_Z2
         Zlfc(i,j)=Z2;
         break
      end
       
    end
    
   
   
   
  end    
end
%%
figure('Position',[100 65 800 600])
plot(hgt(:,100)); hold on
plot(Zlcl(:,100))
plot(Zlfc(:,100))

