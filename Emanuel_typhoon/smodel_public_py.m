%
%  Simple time-dependent model including variable outflow temperature
%   K. Emanuel, October-November 2010
%
%---------------------------------------------------------------------
%
%  Constants and control parameters
%  (Number in parentheses are default values)
%
endtime=12;     % End time (days) of integration
%
Cd=1.0e-3;      % Drag coefficient (1.0e-3)
Ck=1.0e-3;      % Enthalpy exchange coefficient (1.0e-3)
vcap=200;       % Capping wind speed (m/s) in surface enthalpy flux (200, means no cap)
wsmin=0;        % Gustiness (m/s) in surface flux formulation (0)
shear=0;        % Environmental wind shear (kts; parameterized effect; default=0)
Tt=200.0;       % Minimum outflow temperature (tropopause temperature) (200.0)
Tb=300.0;       % Surface temperature (300.0)
the0=370;       % Sea surface theta_e (370.)
themax=345.15;  % Peak theta_e in starting vortex (345.15; Should be only slightly greater than theenv)
theenv=345;     % Ambient boundary layer theta_e (345)
thedecay=200;   % Radial decay rate of theta_e in starting vortex (200)
rcool=0.5;      % Constant radiative cooling rate (deg/day) (0.5)
taudamp=10;     % Time scale (days) of damping of PBL entropy (10)
lmix=100;       % Mixing length (m) in diffusion of PBL entropy (100)
tauout=1.5;     % Time scale (days) to relax outflow temperature (1.5)
weight=1;       % PBL entropy advection weighting; 0.5 = centered, 1.0 = upstream (1)
eyediff=0.7;    % Sets temperature of eye: 1 = near sold-body rotation; 0 = no adjustment (0.7) 
%
h=5000.0;       % Depth (m) over which surfaces fluxes converge (5000)
r0=400.0e3;     % Outer radius (m) of starting vortex (400e3)
rt=15e3;        % Radius (m) needed in critical outflow formulation (15e3; Note:  Modified later in code)
Ric=0.5;        % Critical Richardson Number (0.5)
Diss=0;         % Coefficient of dissipative heating (1=full heating; 0=no heating)(0)
isoexpand=0;    % Coefficient governing pressure dependence of surface saturation entropy (0-1)(0)
%
dt=100.0;       % Time step (s) (100)
afilt=0.1;      % Asselin filter value (0.1)
nr=400;         % Number of radial nodes (M-coordinate model) (400)
%
cp=1005.0;      % Heat capacity at constant pressure (1005)
f=5.0e-5;       % Coriolis parameter (5e-5)
smid=1;
%
%-------------------------------------------------------------------------
%
fwait = waitbar(0,'Program running'); % Displays progress bar
%
rt=rt*min(Cd/Ck,1);  %  Empirical modification of rt to help with smooth time evolution
hi=1./h;
cfac=Ck/Cd;
if cfac == 2         % Just to avoid (removable) singularity
    cfac=1.99;
end    
M0=0.5*f*r0^2;       % Outermost value of angular momentum
dM=M0/nr;
dMi=1./dM;
dti=1./dt;
M=0:dM:M0;           % Specify M grid
nr=max(size(M));
endtime=endtime*24.0*3600.0;
taui=1./(24.*3600.*taudamp);
tauouti=1./(24.*3600.*tauout);
rcool=rcool.*cp./(Tb.*24.*3600);
dampnorm=5000.*hi;
shear=shear*0.02/500;
nt=1+floor(endtime./dt);
%
% Base value of surface saturation mixing ratio (added February 2018)
%
Tcs=Tb-273.15;
es0=6.112*exp(17.67*Tcs./(243.5+Tcs));
qs0=0.622*es0./(1000-es0);
%
%  Set initial vortex saturation entropy
%
s0=cp.*log(the0);
se=cp.*(log(theenv));
s1=cp.*log(themax)-cp.*log(themax./theenv).*(1-exp(-thedecay.*M.^2./M0.^2));
s2=s1;
%
% Set other initial conditions
%
t=0;
dssdM=zeros(1,nr);
dsdM=zeros(1,nr);
%
dsdM1=zeros(1,nr);
dsdM2=zeros(1,nr);
sf=zeros(1,nr);
%
vt=zeros(1,nt);
rmt=zeros(1,nt);
jmax=10;
r(1:nr)=50e3;
V(1:nr)=1;
adv=zeros(1,nr);
u1=zeros(1,nr);
u2=zeros(1,nr);
dMdr1=zeros(1,nr);
dMdr2=dMdr1;
dr3=zeros(1,nr);
jmin=nr;
Vmax=0;
psi(1)=0;
n=0;
T(1:nr)=Tt;
T1=T;
T2=T;
x(1:nr)=0;
clear vtemp
rifac=sqrt(Cd*Ric/Ck);
int=1;
%
% Begin time marching
%
while t <= endtime
    n=n+1;
    t=t+dt;
    %
    if t > int
        int=int+3*24*3600;
        waitbar(int/endtime,fwait,'Program running');
    end    
    %
    smax=s1(jmax);  % Value of entropy at radius of maximum winds
    %
    dsdM1(1:nr-1)=(s1(2:nr)-s1(1:nr-1)).*dMi; % M gradient of PBL entropy
    dsdM2(2:nr)=dsdM1(1:nr-1); % M gradient of PBL entropy
    dsdM1(nr)=dsdM1(nr-1);
    dsdM2(nr)=dsdM2(nr-1);
    dssdM(2:nr-1)=0.5*(s1(3:nr)-s1(1:nr-2)).*dMi; % M gradient of Sat. entropy
    dssdM(1)=0;
    dssdM(nr)=dssdM(nr-1);
    [dum2, jss]=min((Tb-T1).*dssdM);    % Max value of -ds*/dM * (Tb-T)
    dssmin=dssdM(jss);
    dssdM(1:jss-1)=eyediff*dssmin+(1-eyediff).*(dssdM(1:jss-1));  % Set -ds*/dM to max value inside location of max value
    dssdM=min(dssdM,0);     % Make sure -ds*/dM is positive or zero
    %
    % Find outflow temperature by integrating outflow layer critical
    % equation for dT/dM
    %
    if n == 1
        T=Tt+(Tb-Tt).*(smax-s1)./(smax-se); %Used only in first time step
        T1=T;
        T2=T;
    else
        T(1:jmax)=Tt; % Outflow T at and inside radius of maximum wind
        x(jmax)=log(Tb-Tt); % Log of (T_b-T) at radius of maximum winds
        %
        % March dx/dM outward from jmax
        %
        for j=jmax+1:nr
            vrmean=0.5.*(V(j)./r(j)+V(j-1)./max(r(j-1),1));
            x(j)=x(j-1)-(Ric./rt.^2.)*(M(j)-M(j-1))./(vrmean+0.5.*f);
        end  
        T(jmax+1:nr)=Tb-exp(x(jmax+1:nr)); % Calculate T from x
    end
    %
    T=min(T,Tb);    % Do not allow outflow T to exceed Tb
    T=max(T,Tt);    % Do not allow outflow T to be less than Tt
    Tmax=T(jmax);   % Outflow temperature at radius of max winds
    %
    r=sqrt(M./(0.5.*f-(Tb-T2).*dssdM)); % Find radius
    for i=nr-1:-1:1                    % Condition radii to be monotonic
        r(i)=min(r(i),r(i+1));
    end    
    %
    V=M./r-0.5.*f.*r;                  % Find Azimuthal velocity
    V(nr)=2.*V(nr-1)-V(nr-2);
    %Vtr(n,:)=V;
    V=max(V,0);
    [Vmax, jmax]=max(V);               % Find max value of V and location of max value
    [dum, jmin]=min(V(2:nr));  
    %
    vt(n)=Vmax;                 % Time series of Vmax for plotting
    rmt(n)=0.001.*r(jmax);      % Time series of radius of maximum winds
    rtnew=r(jmax)*rifac;        % Revised estimate of rt
    rt=0.7*rt+0.3*rtnew;
    %
    % Calculate forcing of boundary layer entropy and outflow temperature
    %
    Tf=(T-T1).*tauouti;
    %
    % The following makes a smooth transition to vcap, to avoid abrupt changes
    %
    ny=5;
    vy=(V.*vcap)./(V.^ny+vcap.^ny).^(1./ny);
    vy(1)=vy(2);
    %
    ws=sqrt(vy.^2+wsmin.^2);
    ws1=sqrt(V.^2+wsmin.^2);
    %
    %  Calculate surface pressure
    %
    if isoexpand ~= 0
        %
        % Account for variable To along inflow trajectory (added 2/18)
        %
        sx=zeros(1,nr);
        for i=nr-1:-1:1
            sx(i)=sx(i+1)-(Tb-0.5*(T(i)+T(i+1)))*(s2(i+1)-s2(i));
        end    
        alogp=-(0.5.*V.*V+0.5*f*(M-M0)+sx)./(287.*Tb); % Inserted 2/18
        %
        pp0=exp(alogp);
        s0mod=s0+isoexpand*qs0.*2.5e6.*(1./pp0-1)./Tb-287*isoexpand.*alogp; % Changed 0.02 to qs0 2/2018
    else
        s0mod=s0;
    end        
    %
    % calculate forcing (sf) of boundary layer entropy equation
    %
    term1=Cd.*r.*V.*ws1;
    %
    u2(1:nr-1)=0.5*(term1(2:nr)+term1(1:nr-1));
    u1(2:nr)=u2(1:nr-1);
    adv=weight*u2.*dsdM1+(1-weight)*u1.*dsdM2;
    %
    sf=(adv+Ck.*ws.*(s0mod-s1)+Diss.*Cd.*ws1.*V.^2./Tb).*hi;
    sf=sf-shear.*ws.*(s1-smid).*hi;  % Parameterized shear effect
    %
    %  Add thermal damping 
    %
    sf=sf-rcool;
    %
    % Time stepping (leap frog with Asselin filter)
    %
    s3=s1+2.*dt.*sf;
    s3=max(s3,se);
    s1=s2+afilt.*(s1+s3-2.*s2);
    s1=max(s1,se);
    s2=s3;
    T3=T1+2.*dt.*Tf;
    T3=max(T3,Tt);
    T3=min(T3,Tb);
    T1=T2+afilt.*(T1+T3-2.*T2);
    T2=T3;
    %
    %  Some boundary conditions
    %
    s2(nr)=2.*s2(nr-1)-s2(nr-2);
    s1(nr)=2.*s1(nr-1)-s1(nr-2);
    s1(1)=2.*s1(2)-s1(3);
    s2(1)=2.*s2(2)-s2(3);
    %
end
%
% Calculate streamfunction from PBL angular momentum balance
%   and then calculate vertical velocity
%
psi(2:nr)=-Cd.*(r(2:nr).*V(2:nr)).^2.*(r(2:nr)-r(1:nr-1)).*dMi;
w(2:nr-1)=-2.*(psi(3:nr)-psi(1:nr-2))./(r(3:nr).^2-r(1:nr-2).^2);
w(1)=w(2);
w(nr)=0;
w(3:nr-2)=smooth3(w);
%
% Calculate saturation entropy for plotting
%
ss=s1;
ss(1:jmax)=ss(jmax)+(Vmax.^2./(Tb-Tmax)).*(1.0-M(1:jmax)./...
    M(jmax));
ss=max(ss,s1);
%
nt=max(size(vt));
time=dt:dt:nt*dt;
time=time./(24.*3600);
%
% Calcualte potential intensity from theory
s0p=s0;
if isoexpand ~= 0
    [~,imax]=max(V);
    s0p=s0mod(imax);
end    
vtheory=sqrt((Diss.*Tb+(1-Diss).*Tt).*Ck.*(Tb-Tt).*(s0p-se)./(Tt.*(Cd))); % Raw potential intensity (diagnostic only)
[vtheory] = vpotcalc( vtheory,Ck,Cd,vcap );  % Calculates correction to potential intensity
vtheory=vtheory/sqrt(2);
%
close(fwait)
%
% Plot various quantitites
%
indx=1;
while isempty(indx) == 0
    items={'Maximum wind speed vs. time','Radial profile of V at final time', ...
        'Radial profile of u at final time','Radial profile of w at final time', ...
        'Radial profiles of entropy at final time'};
    [indx,tf] = listdlg('PromptString','Select a plot:',...
                               'SelectionMode','single',...
                               'CancelString','Stop', ...
                               'ListSize',[220 120], ...
                               'ListString',items);
    if indx == 1
        vtemp(1:nt)=vtheory;
        h2=plot(time,vt,time,vtemp);
        set(gca,'fontweight','bold')
        set(h2,'linewidth',2);
        xlabel('Time (days)')
        ylabel('Azimuthal wind (m/s)')
        title('Azimuthal Wind Time Series')
        %
        vt2=vtheory.*tanh(0.5*max(Cd,Ck)*vtheory*hi*time*24*3600);
        hold on
        j=plot(time,vt2,'--r','linewidth',2);
        hold off
        legend('Azimuthal Wind','Potential Intensity','Analytic approximation','location','best')
    elseif indx == 2
        h1=plot(0.001.*r,V);
        set(gca,'fontweight','bold') 
        set(h1,'linewidth',2);
        xlabel('Radius (km)')
        ylabel('Azimuthal wind (m/s)')
        title('Radial Profile of Azimuthal Wind at Final Time')
    elseif indx == 3
        u=hi.*psi./r;
        h3=plot(0.001.*r,u);
        set(gca,'fontweight','bold') 
        set(h3,'linewidth',2);
        xlabel('Radius (km)')
        ylabel('Radial wind (m/s)')
        title('Radial Profile of Radial Wind at Final Time')
    elseif indx == 4
        h4=plot(0.001.*r,w);
        set(gca,'fontweight','bold') 
        set(h4,'linewidth',2);
        xlabel('Radius (km)')
        ylabel('Vertical wind (m/s)')
        title('Radial Profile of Vertical Wind at Final Time')
    elseif indx == 5
        %
        h5=plot(0.001.*r,exp(s1./cp),'b',0.001.*r,exp(ss./cp),'r');
        set(gca,'fontweight','bold') 
        set(h5,'linewidth',2);
        xlabel('Radius (km)')
        ylabel('\theta_e (K)')
        legend('PBL \theta_e','\theta_e^*')
        title('Radial Profile of PBL \theta_e and \theta_e^* at Final Time')
    end
end    
%--------------------------------------------------------------------------
