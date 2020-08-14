function du2=leapfrog_TLM(du0,du1,u1,dt,dx,gamma,xnu)
 
Ndim=length(du0);
du2=zeros(Ndim,1);

for i=1:Ndim %space    
  ip=i+1;  if i==Ndim; ip=1; end
  ipp=i+2; if i>=Ndim-1; ipp=i+2-Ndim; end
  im=i-1; if i==1; im=Ndim; end
  imm=i-2; if i<=2; imm=i-2+Ndim; end
  %---  
  dA = ( (-2*u1(ip)-u1(i))*du1(ip) - (u1(ip)-u1(im))*du1(i) + (u1(i)+2*u1(im))*du1(im) )/6*dx;
  dD = -gamma^2 * (du1(ipp)-2*du1(ip)+2*du1(im)-du1(imm)) / (2*dx^3);
  dS = xnu * (du0(ip)-2*du0(i)+du0(im)) / dx^2;     

  du2(i) = du0(i) + 2 * dt * (dA + dD + dS);  
    
end %Ndim  