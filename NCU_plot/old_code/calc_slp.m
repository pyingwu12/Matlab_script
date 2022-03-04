function [slp]=calc_slp(pressure,zg,temp,qv);
nz=size(pressure,1);
ny=size(pressure,2);
nx=size(pressure,3);
pconst=10000.0;
GAMMA = 0.0065;
Rd = 287.04;
G=9.81;
%TC=273.16+17.5;
TC=273.16+28;

for j= 1:ny
for i = 1 :nx

   level(j,i)=min(find(pressure(:,j,i)< (pressure(1,j,i)-10000)));
   klo = max ( level(j,i) - 1 , 1      );
   khi = min ( klo + 1        , nz - 1 );

   err_mesg='Error_trapping_levels';
   if ( klo == khi );fprintf(1,'%s\n', err_mesg);end

   plo = pressure(klo,j,i);
   phi = pressure(khi,j,i);
   tlo = temp(klo,j,i)*(1. + 0.608 * qv(klo,j,i) );
   thi = temp(khi,j,i)*(1. + 0.608 * qv(khi,j,i) );
   zlo = zg(klo,j,i);
   zhi = zg(khi,j,i);

   p_at_pconst = pressure(1,j,i) - 10000.0;
   t_at_pconst = thi-(thi-tlo)*log(p_at_pconst/phi)*log(plo/phi);
   z_at_pconst = zhi-(zhi-zlo)*log(p_at_pconst/phi)*log(plo/phi);

   t_surf(j,i) = t_at_pconst*(pressure(1,j,i)/p_at_pconst)^(GAMMA*Rd/G);
   t_sea_level(j,i) = t_at_pconst+GAMMA*z_at_pconst;

 end
 end
 for j = 1 :ny
 for i = 1 :nx
     if ( (t_surf(j,i)<=TC) & ( t_sea_level(j,i) >= TC) ) 
       t_sea_level(j,i) = TC;
     else
       t_sea_level(j,i) = TC - 0.005*(t_surf(j,i)-TC)^2;
     end
 end 
 end 

for j = 1 :ny
for i = 1:nx
  z_half_lowest=zg(1,j,i);
  slp(j,i) = pressure(1,j,i)*exp((2.*G*z_half_lowest)/(Rd*(t_sea_level(j,i)+t_surf(j,i))));
end
end
slp = slp*0.01;

