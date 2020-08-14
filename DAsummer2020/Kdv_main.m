%Kdv main
clear
close all
%=============basic setting================
%---model
Ndim = 40;
dx = 10.0;
dt = 0.5;
KTmax=1200; % total integration step
gamma = 20.0;
xnu = 0.2;

%---obs
global t_obsint Hmat

Nobs = 8;                      %obs numbers in space
s_obsint = floor(Ndim / Nobs); %obs space interval
t_obsint = 15;                 %obs time interval (step)
robs=0.5;                      %obs error
%---obs operator, Hx=y
Hmat=zeros(Nobs,Ndim); 
p_loc=1:s_obsint:Ndim;
%p_loc=[1 6 7 8 15 16 18 25 27 29 33 38 40]; Nobs = length(p_loc); 
for p=1:Nobs
Hmat(p,p_loc(p))=1;
end
%%
%=============creat true state and obs================
%---initial condition---
x0=200; alpha=16;
ut=zeros(Ndim,KTmax+1);
for i=1:Ndim
ut(i,1)=alpha/(exp((i*dx-x0)/(48/alpha)^0.5/gamma)+exp(-(i*dx-x0)/(48/alpha)^0.5/gamma))^2;
end
%---make true state and obs----
p=0; yobs=zeros(Nobs,KTmax/t_obsint);
for t=1:KTmax     
  if t==1
   ut(:,t+1)=forward(ut(:,t),dt,dx,gamma,xnu);  
  else
   ut(:,t+1)=leapfrog(ut(:,t-1),ut(:,t),dt,dx,gamma,xnu);
  end
  if mod(t,t_obsint)==0
     p=p+1;
     yobs(:,p)=Hmat * ut(:,t+1) + robs * randn(Nobs,1);
  end
end %time
%save(['true_obs_',num2str(Nobs),'_',num2str(t_obsint),'_',num2str(robs),'.mat'],'ut','yobs')
%%
%=============no DA================
%---different initial condiction from true
x0=10; b=110; a=5;
uf=zeros(Ndim,KTmax+1);
for i=1:Ndim
uf(i,1)=a*exp( -((i*dx-x0)/b)^2 );
end
%---free forecast
for t=1:KTmax        
  if t==1
   uf(:,t+1)=forward(uf(:,t),dt,dx,gamma,xnu);  
  else
   uf(:,t+1)=leapfrog(uf(:,t-1),uf(:,t),dt,dx,gamma,xnu);
  end      
end %time
%%
%load('true_obs_8_15_0.5.mat')
%============= PLOT ================
% exp_setting_tit=['KTwin= ',num2str(KTwin),', robs=',num2str(robs),', Nobs=',num2str(Nobs),', t_obsint=',num2str(t_obsint),...
%     ' sigma_f=',num2str(sigma_f),', L=',num2str(L)];
% exp_setting_file=['w',num2str(KTwin),'_ro',num2str(robs*10,'%.2d'),'_No',num2str(Nobs),'_to',num2str(t_obsint),'_rf',...
%     num2str(sigma_f),'_L',num2str(L)];
filename='4DVARmod';
%%
%=============================================================
%---RMSE for different window
n=0; robs = 0.5; sigma_f=2; KTwin = 210;  L=3;
rmse_a=zeros(1,KTmax+1);
 for nwin=30:60:350
   n=n+1;   
   uest=zeros(Ndim,KTmax+1);
   uest(:,1)=uf(:,1);
   uest=run4DVAR(uest,yobs,nwin,robs,sigma_f,L,dt,dx,gamma,xnu);
   rmse_a(n,:)=(sum((uest-ut).^2,1)/Ndim).^0.5;
 end
 
exp_setting_tit=['robs=',num2str(robs),', Nobs=',num2str(Nobs),', t_obsint=',num2str(t_obsint),', sigma_f=',num2str(sigma_f),', L=',num2str(L)];
exp_setting_file=['ro',num2str(robs*10,'%.2d'),'_No',num2str(Nobs),'_to',num2str(t_obsint),'_rf',num2str(sigma_f),'_L',num2str(L)];

hf2=figure('position',[100 50 1000 600]);
plot(rmse_a','LineWidth',2.5);
legend('KTwin=30','KTwin=90','KTwin=150','KTwin=210','KTwin=270','KTwin=330','fontsize',16)
set(gca,'LineWidth',1.2,'FontSize',16,'Xlim',[1 KTmax+1])
xlabel('Time step','FontSize',18)
title({'RMSE',exp_setting_tit},'Interpreter','none','fontsize',15)
% outfile=['/mnt/e/DA_summer_school_2020/4DVAR_rmse_',exp_setting_file];
outfile=[filename,'_rmse_',exp_setting_file]; 
print(hf2,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%%
%=============================================================
%---RMSE for different robs
n=0; robs = 0.5; sigma_f=2; KTwin = 210;  L=3;
rmse_a=zeros(1,KTmax+1);
 for nrobs=0.1:0.2:1.1
   n=n+1;   
   uest=zeros(Ndim,KTmax+1);
   uest(:,1)=uf(:,1);
   uest=run4DVAR(uest,yobs,KTwin,nrobs,sigma_f,L,dt,dx,gamma,xnu);
   rmse_a(n,:)=(sum((uest-ut).^2,1)/Ndim).^0.5;
 end

exp_setting_tit=['KTwin= ',num2str(KTwin),', Nobs=',num2str(Nobs),', t_obsint=',num2str(t_obsint),', sigma_f=',num2str(sigma_f),', L=',num2str(L)];
exp_setting_file=['w',num2str(KTwin),'_No',num2str(Nobs),'_to',num2str(t_obsint),'_rf',num2str(sigma_f),'_L',num2str(L)];
%
hf2=figure('position',[100 50 1000 600]);
plot(rmse_a','LineWidth',2.5);
legend('robs=0.1','robs=0.3','robs=0.5','robs=0.7','robs=0.9','robs=1.1','fontsize',16)
set(gca,'LineWidth',1.2,'FontSize',16,'Xlim',[1 KTmax+1],'Ylim',[0 0.6])
xlabel('Time step','FontSize',18)
title({'RMSE',exp_setting_tit},'Interpreter','none','fontsize',15)
% outfile=['/mnt/e/DA_summer_school_2020/4DVAR_rmse_',exp_setting_file];
outfile=[filename,'_rmse_',exp_setting_file]; 
print(hf2,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%%
%=============================================================
%---RMSE for different sigma_f
n=0; robs = 0.5; sigma_f=2; KTwin = 210;  L=3;
rmse_a=zeros(1,KTmax+1);
 for nsigf=0.5:0.5:3
   n=n+1;   
   uest=zeros(Ndim,KTmax+1);
   uest(:,1)=uf(:,1);
   uest=run4DVAR(uest,yobs,KTwin,robs,nsigf,L,dt,dx,gamma,xnu);
   rmse_a(n,:)=(sum((uest-ut).^2,1)/Ndim).^0.5;
 end
%
exp_setting_tit=['KTwin= ',num2str(KTwin),', robs=',num2str(robs),', Nobs=',num2str(Nobs),', t_obsint=',num2str(t_obsint),', L=',num2str(L)];
exp_setting_file=['w',num2str(KTwin),'_ro',num2str(robs*10,'%.2d'),'_No',num2str(Nobs),'_to',num2str(t_obsint),'_L',num2str(L)];

hf2=figure('position',[100 50 1000 600]);
plot(rmse_a','LineWidth',2.5);
legend('sigma_f=0.5','sigma_f=1','sigma_f=1.5','sigma_f=2','sigma_f=2.5','sigma_f=3','fontsize',16,'Interpreter','none')
set(gca,'LineWidth',1.2,'FontSize',16,'Xlim',[1 KTmax+1])
xlabel('Time step','FontSize',18)
title({'RMSE',exp_setting_tit},'Interpreter','none','fontsize',15)
% outfile=['/mnt/e/DA_summer_school_2020/4DVAR_rmse_',exp_setting_file];
outfile=[filename,'_rmse_',exp_setting_file]; 
print(hf2,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
%%
%=============================================================
nf=0;no=0; 
n=0; robs = 0.5; sigma_f=2; KTwin = 210;  L=3;

robs=0.1:0.2:1.1;
sigma_f=0.5:0.5:3;
rmse_a=zeros(length(robs),length(sigma_f));
for nrobs=1:length(robs)
 for nsigf=1:length(sigma_f)
    disp( ['robs=',num2str(robs(nrobs))])
    disp( ['sigma_f=',num2str(sigma_f(nsigf))])
   uest=zeros(Ndim,KTmax+1);
   uest(:,1)=uf(:,1);
   uest=run4DVAR(uest,yobs,KTwin,robs(nrobs),sigma_f(nsigf),L,dt,dx,gamma,xnu);
   rmse_a(nrobs,nsigf)=mean((sum((uest-ut).^2,1)/Ndim).^0.5);
 end
end
 %%
exp_setting_tit=['KTwin= ',num2str(KTwin),', Nobs=',num2str(Nobs),', t_obsint=',num2str(t_obsint),', L=',num2str(L)];
exp_setting_file=['w',num2str(KTwin),'_No',num2str(Nobs),'_to',num2str(t_obsint),'_L',num2str(L)];

hf2=figure('position',[100 50 800 630]);
imagesc(rmse_a);
hc=colorbar; title(hc,'RMSE','fontsize',15)
set(gca,'LineWidth',1.2,'FontSize',16,'XTicklabel',sigma_f,'YTicklabel',robs)
xlabel('sigma_f','FontSize',18,'Interpreter','none'); ylabel('robs','FontSize',18);
title({'RMSE',exp_setting_tit},'Interpreter','none','fontsize',15)
% outfile=['/mnt/e/DA_summer_school_2020/4DVAR_rmse_',exp_setting_file];
outfile=[filename,'_rmse_',exp_setting_file]; 
print(hf2,'-dpng',[outfile,'.png'])
% system(['convert -trim ',outfile,'.png ',outfile,'.png']);
