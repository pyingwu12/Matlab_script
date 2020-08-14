function du1=forward_TLM(du0,u0,dt,dx,gamma,xnu)
 
Ndim=length(du0);
du1=zeros(Ndim,1);
for i=1:Ndim %space    
  ip=i+1;  if i==Ndim; ip=1; end
  ipp=i+2; if i>=Ndim-1; ipp=i+2-Ndim; end
  im=i-1; if i==1; im=Ndim; end
  imm=i-2; if i<=2; imm=i-2+Ndim; end
  %---    
  dA = ( (-2*u0(ip)-u0(i))*du0(ip) - (u0(ip)-u0(im))*du0(i) + (u0(i)+2*u0(im))*du0(im) )/6*dx;
  dD = -gamma^2 * (du0(ipp)-2*du0(ip)+2*du0(im)-du0(imm)) / (2*dx^3);
  dS = xnu * (du0(ip)-2*du0(i)+du0(im)) / dx^2;     

  du1(i) = du0(i) + dt * (dA + dD + dS);  
    
end %Ndim  