function zh_max=cal_zh_cmpo(infile,scheme)
  
  % zh_max=cal_zh_cmpo(infile,scheme)
  % Compute simulated Zh composite of WRF
  % <infile>: Path of the wrf file.
  % <scheme>: Microphysic scheme. Available now: Lin/Gaddard/WSM6

   qr = ncread(infile,'QRAIN');  qr=double(qr);   
   qv = ncread(infile,'QVAPOR'); qv=double(qv);
   qs = ncread(infile,'QSNOW');  qs=double(qs);    
   qg = ncread(infile,'QGRAUP'); qg=double(qg);
   p = ncread(infile,'P');       p=double(p);           
   pb = ncread(infile,'PB');     pb=double(pb);
   t = ncread(infile,'T');       t=double(t);
   %---
   [nx,ny,nz]=size(qr);  zh=zeros(nx,ny,nz);

   temp=(300.0+t).*((p+pb)/1.e5).^(287/1005);
   den=(p+pb)/287.0./temp./(1.0+287.0*qv/461.6);   
   
   switch scheme   
     case ('WSM6')      %---WSM6 scheme---
       fin=find(temp < 273.15);
       zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.33e09*(den(fin).*qs(fin)).^1.75+1.18e09*(den(fin).*qg(fin)).^1.75);
       fin=find(temp >= 273.15);
       zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+5.77e11*(den(fin).*qs(fin)).^1.75+1.18e09*(den(fin).*qg(fin)).^1.75);       
     case ('Gaddard')   %---Gaddard scheme---
       fin=find(temp < 273.15);
       zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+2.79e8*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
       fin=find(temp >= 273.15);
       zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+1.21e11*(den(fin).*qs(fin)).^1.75+1.12e9*(den(fin).*qg(fin)).^1.75);
     %--- 
     case ('Lin')      %---Lin scheme---
       fin=find(temp < 273.15);
       zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+9.80e8*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);
       fin=find(temp >= 273.15);
       zh(fin)=10.0*log10(3.63e9*(den(fin).*qr(fin)).^1.75+4.26e11*(den(fin).*qs(fin)).^1.75+4.33e10*(den(fin).*qg(fin)).^1.75);       
   end % end of case
   
   zh(zh<0)=0;
   zh=real(zh);
   zh_max=max(zh,[],3);         
      
end  % end of function