% test TLM


clear

Ndim = 40;

%model
dx = 10.0;
dt = 0.5;
gamma = 20.0;
xnu = 0.2;

KTmax=10;

del_u=0.001;

%---initial condition---
ut=zeros(Ndim,KTmax);
for i=1:Ndim
ut(i,1)=16/(exp((i*dx-200)/3^0.5/gamma)+exp(-(i*dx-200)/3^0.5/gamma))^2;
end

 dut=zeros(Ndim,KTmax);
 dut(:,1)=del_u;
 
utdu=zeros(Ndim,KTmax);
utdu(:,1)=ut(:,1)+del_u;

p=0; 
for t=1:KTmax-1
  if t==1
   ut(:,t+1)=forward(ut(:,t),dt,dx,gamma,xnu);  
   utdu(:,t+1)=forward(utdu(:,t),dt,dx,gamma,xnu);  
   dut(:,t+1)=forward_TLM(dut(:,t),ut(:,t),dt,dx,gamma,xnu);
  else
   ut(:,t+1)=leapfrog(ut(:,t-1),ut(:,t),dt,dx,gamma,xnu);
   utdu(:,t+1)=leapfrog(utdu(:,t-1),ut(:,t),dt,dx,gamma,xnu);
   dut(:,t+1)=leapfrog_TLM(dut(:,t-1),dut(:,t),ut(:,t-1),dt,dx,gamma,xnu);
  end
end %time

figure
subplot(1,2,1)
contourf(ut','LineStyle','none')
subplot(1,2,2)
contourf(dut','LineStyle','none')